package org.seaview.main;

import org.seaview.main.Crawl;
import org.seaview.data.Viewer;
import org.seaview.data.OldViewer;
import org.shanghai.rdf.Config;
import org.shanghai.crawl.FileTransporter;
import org.shanghai.crawl.TrivialScanner;
import com.hp.hpl.jena.rdf.model.Model;
import java.util.ArrayList;
import java.util.logging.Logger;

/**
    @license http://www.apache.org/licenses/LICENSE-2.0
    @author Goetz Hatop
    @title A data crawler, more general than parent.
    @date 2013-02-23
*/
public class Main extends org.shanghai.crawl.Main {

    protected String source = null;
    protected String target = null;
    protected String engine = null;

    @Override
    public void create() {
        config = new Config(configFile).create();
        crawl = new Crawl(config);
        if (source==null && target==null && engine==null) {
            crawl.create();
        } else {
            crawl.create(source, target, engine);
        }
    }

    @Override
    public void dispose() {
        super.dispose();
    }

    @Override
    public void make(String[] args) {
        if (args.length>1 && args[0].equals("-crawl")) {
            ArrayList<String> result = new ArrayList<String>();
            result.add(args[0]);
            for (int i=1; i<args.length; i++) {
                if (args[i].startsWith("-conf")) {
                    configFile = args[++i];
				} else if (args[i].equals("-s")) {
				    source = args[++i];
				} else if (args[i].equals("-t")) {
				    target = args[++i];
				} else if (args[i].equals("-e")) {
				    engine = args[++i];
				} else {
			        result.add(args[i]);
				}
            }
            super.make(result.toArray(new String[result.size()]));
        } else if (args.length>2 && args[0].startsWith("-viewer")) {
            config = new Config(configFile).create();
            String xslt = config.get("opus.viewer");
            boolean test = args[0].equals("-viewer:debug");
            Viewer viewer = new Viewer(args[1], args[2], xslt, test);
            viewer.create();
            viewer.transform();
            viewer.dispose();
        } else if (args.length>2 && args[0].startsWith("-oview")) {
            //GH201506: new version intendend
            log("Attention: starting old viewer"); 
            config = new Config(configFile).create();
            String xslt = config.get("opus.viewer");
            boolean test = args[0].equals("-oview:debug");
            OldViewer viewer = new OldViewer(args[1], args[2], xslt, test);
            viewer.create();
            viewer.transform();
            viewer.dispose();
        } else { 
            super.make(args);
        }
    }

    private void log(String msg) {
        logger.info(msg);
    }

    private static final Logger logger =
                         Logger.getLogger(Main.class.getName());

    public static void main(String[] args) {
        Main main = new Main();
        main.make(args);
    }
}
