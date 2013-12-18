package org.shanghai.crawl;

import org.shanghai.rdf.RDFTransporter;
import com.hp.hpl.jena.rdf.model.Model;
import java.util.logging.Logger;

/**
   @license http://www.apache.org/licenses/LICENSE-2.0
   @author Goetz Hatop
   @title Small wrapper for RDF data from TDB store
   @date 2013-12-01
*/
public class TDBTransporter implements MetaCrawl.Transporter {

    private RDFTransporter transporter;

    public TDBTransporter(String sparql,
            String probe, String enum_, String dump, String date) {
        transporter = new RDFTransporter(sparql, probe, enum_, dump, date);
    }

    @Override 
    public void create() {
        transporter.create();
    }

    @Override 
    public void dispose() {
        transporter.dispose();
    }

    @Override 
    public String probe() {
        return transporter.probe();
    }

    @Override 
    public Model read(String resource) {
        return transporter.read(resource);
    }

    @Override 
    public String[] getIdentifiers(int off, int limit) {
        return transporter.getIdentifiers(off, limit);
    }

    @Override 
    public int crawl(String directory) {
        return Integer.parseInt(transporter.probe());
    }

    @Override 
    public boolean canRead(String resource) {
        return true;
    }

    private static final Logger logger =
                         Logger.getLogger(TDBTransporter.class.getName());

    private void log(String msg) {
        logger.info(msg);
    }

    private void log(Exception e) {
        log(e.toString());
    }

}
