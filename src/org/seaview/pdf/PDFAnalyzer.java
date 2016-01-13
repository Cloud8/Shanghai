package org.seaview.pdf;

import org.shanghai.util.Language;
import org.shanghai.util.FileUtil;
import org.shanghai.crawl.MetaCrawl;

import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.rdf.model.Resource;
import org.apache.jena.rdf.model.Property;
import org.apache.jena.rdf.model.Statement;
import org.apache.jena.vocabulary.DCTerms;
import org.apache.jena.vocabulary.RDF;
import org.apache.jena.vocabulary.RDFS;
import org.apache.jena.rdf.model.StmtIterator;
import org.apache.jena.rdf.model.Seq;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.rdf.model.RDFNode;
import org.apache.jena.shared.PropertyNotFoundException;

import org.jdom.Element;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
import java.util.logging.Logger;

/*
    @license http://www.apache.org/licenses/LICENSE-2.0
    @author Goetz Hatop
    @title Reference extractor for pdf files
    @date 2015-05-08
 */
public class PDFAnalyzer implements MetaCrawl.Analyzer {

    protected static final int MONOSIZE = 33; // pages considered mono
    protected static final int MONOTHRESHOLD = 29; // minimum # references
    protected static final String about /* will become rdf:about */
                                        = "http://localhost/refs/";

    private boolean meta;
    private boolean refs;
    private int threshold;
    private PDFLoader pl;
    private Cover cover;
    private AbstractExtractor extractor;
    private Language language;
    public int count;

    public PDFAnalyzer(String engine, boolean meta, boolean refs, String ghome)
    {
        if (engine.equals("cermine")) {
            extractor = new Cermine(meta, refs);
        } else if (engine.equals("grobid")) {
            extractor = new Grobid(meta, refs, ghome);
        } else {
            extractor = new AbstractExtractor(meta, refs);
        }
        this.meta = meta;
        this.refs = refs;
        language = new Language();
        pl = null;
    }

    public PDFAnalyzer(String engine, boolean meta, boolean refs, 
                       String ghome, String docbase) {
        this(engine, meta, refs, ghome);
        pl = new PDFLoader(docbase);
    }

    @Override
    public void dispose() {
        extractor.dispose();
        cover.dispose();
        language.dispose();
        pl.dispose();
    }

    @Override
    public String probe() {
        return " " + extractor.getClass().getName();
    }

    @Override
    public MetaCrawl.Analyzer create() {
        //log("create metadata " + title + " references " + refs);
        count = 0;
        extractor.create();
        if (pl==null) {
            pl = new PDFLoader();
        }
        cover = new Cover(pl);
        cover.create();
        language.create();
        pl.create();
        return this;
    }

    @Override
    public Resource test(Resource rc) {
        log("test: " + rc.getURI()); 
        String fname = create(rc);
        if (fname==null) {
            log("test: no pdf file found for " + rc.getURI());
            return rc;
        }
        extractor.test = true;
        extractor.create(fname);
        if (meta) {
            log("scratch metadata " + rc.getURI());
            extractMetadata(rc, fname);
        }
        if (refs&&(!rc.hasProperty(DCTerms.references))) {
            log("scratch references " + rc.getURI());
            extractReferences(rc, fname);
        }
        // makeTEI(rc); -- may be later
        return rc;
    }

    @Override
    public Resource analyze(Resource rc) {
        log("analyze: " + rc.getURI()); // dumped to crawl.test
        if (rc==null) {
            log("fatal: zero resource.");
            return rc;
        }
        if (refs && (rc.hasProperty(DCTerms.references))) {
            remove(rc, DCTerms.references);
            log("removed references " + rc.getURI());
            //return rc;
        }
        String maltreated = create(rc);
        if (maltreated==null) {
            log("fatal: no pdf file found for " + rc.getURI());
            return rc;
        }

        extractor.create(maltreated);
        if (meta) {
            extractMetadata(rc, maltreated);
        }

        if (refs && (!rc.hasProperty(DCTerms.references))) {
            extractReferences(rc, maltreated);
            if (rc.hasProperty(DCTerms.references)) {
                RDFNode node = rc.getProperty(DCTerms.references).getObject();
                if (node.isResource()) {
                    Resource provenance = rc.getModel().createResource(DCTerms.ProvenanceStatement);
                    provenance.addProperty(RDFS.label, extractor.getClass().getSimpleName());
                    rc.getProperty(DCTerms.references).getResource().addProperty(DCTerms.provenance, provenance);
                }
            }
        }

        cover.analyze(rc);
        language.analyze(rc);

        return rc;
    }

    private String create(Resource rc) {
        pl.analyze(rc);
        if (pl.failed()) {
            return null;
        }
        threshold = 0;
        if (pl.size > MONOSIZE) {
            threshold = MONOTHRESHOLD;
        }
        return pl.maltreat(3, 0.70); // pages 0-3 and 30 % from the tail 
    }

    private void extractMetadata(Resource rc, String fname) {
        extractor.extractMetadata(rc, fname);

        if (!rc.hasProperty(DCTerms.type) 
            && rc.hasProperty(RDF.type, DCTerms.BibliographicResource)) {
			if (pl.size<30) {
			    rc.addProperty(DCTerms.type, "Article");
			} else {
			    rc.addProperty(DCTerms.type, "Book");
			}
		}

        if (!rc.hasProperty(DCTerms.extent)) {
            Resource extent = rc.getModel().createResource(
                                                  DCTerms.SizeOrDuration);
            extent.addProperty(RDF.value, pl.size + " pages.");
            rc.addProperty(DCTerms.extent, extent);
        }

        if (!rc.hasProperty(DCTerms.title)) {
            log("setting title from pdf catalog");
		    if (pl.getTitle()!=null) {
                rc.addProperty(DCTerms.title, pl.getTitle());
            }
        }

        if (!rc.hasProperty(DCTerms.creator) && pl.getAuthor()!=null) {
            log("setting creator from pdf catalog");
            extractor.injectAuthors(rc, new String[]{pl.getAuthor()});
            //rc.addProperty(creator, pl.getAuthor());
        }

        if (!rc.hasProperty(DCTerms.issued) && pl.getDate()!=null) {
            log("setting issue date from pdf catalog");
            rc.addProperty(DCTerms.issued, pl.getDate());
        }
        if (!rc.hasProperty(DCTerms.created) && pl.getDate()!=null) {
            rc.addProperty(DCTerms.created, pl.getDate().substring(0,4));
        }

    }

    private void extractReferences(Resource rc, String fname) {
        extractor.extractReferences(rc, fname, threshold);
    }

    private void remove(Resource rc, Property prop) {
        if (rc.hasProperty(prop)) {
        } else {
            //log("no " + prop + " " + rc.getURI());
            return;
        }
        Seq seq = rc.getProperty(prop).getSeq();
        if (seq!=null && seq.size()>0) {
            for (int i = 1; i<= seq.size(); i++) {
                try {
					Resource obj = seq.getResource(i);
                    StmtIterator si = obj.listProperties();
                    while (si.hasNext()) {
                        Statement stmt = si.nextStatement();
                        if (stmt.getObject().isResource()) {
						    Resource sub = stmt.getResource();
							StmtIterator si2 = sub.listProperties();
							while (si2.hasNext()) {
                                Statement stmt2 = si2.nextStatement();
                                if (stmt2.getObject().isResource()) {
						            Resource sub2 = stmt2.getResource();
									sub2.removeProperties();
									rc.getModel().removeAll(sub2, null, null);
							    }
							}
							//log("rm " + sub.getURI());
                            remove(sub, stmt.getPredicate());
                            sub.removeProperties();
					        rc.getModel().removeAll(sub, null, null);
                        }
                    }
                    obj.removeProperties();
					rc.getModel().removeAll(obj, null, null);
                } catch (PropertyNotFoundException e) { log(e); }
                finally {}
            }
        }
        seq.removeProperties();
        rc.removeAll(prop);
    }

    private void makeTEI(Resource rc) {
        String pdf = pl.getPath(rc);
        String tei = pl.getPath(rc, ".tei");
        String content = extractor.getTEI(pdf);
        if (content==null) {
            log("no TEI from: " + extractor.getClass().getSimpleName());
        } else {
            log("tei path: " + tei);
            FileUtil.write(tei, content);
        }
    }

    private static final Logger logger =
                         Logger.getLogger(PDFAnalyzer.class.getName());

    protected void log(String msg) {
        logger.info(msg);
    }

    protected void log(Exception e) {
        logger.info(e.toString());
    }

    protected void log(Element[] elements) {
        XMLOutputter outp = new XMLOutputter(Format.getPrettyFormat());
        for (Element el : elements) {
            String str = outp.outputString(el);
            System.out.println(str);
        }
    }

    protected void log(Element el) {
        XMLOutputter outp = new XMLOutputter(Format.getPrettyFormat());
        String str = outp.outputString(el);
        System.out.println(str);
    }
}
