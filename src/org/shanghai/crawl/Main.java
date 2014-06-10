package org.shanghai.crawl;

import org.shanghai.rdf.Config;
import org.shanghai.rdf.Indexer;

/**
    @license http://www.apache.org/licenses/LICENSE-2.0
    @author Goetz Hatop
    @title Command Line Interface for the Main RDF Crawler
    @date 2013-03-01
*/
public class Main {

    protected Config config;
    protected Crawl crawl;
    protected static String configFile = "shanghai.ttl";

    public void dispose() {
	    if (crawl!=null)
		    crawl.dispose();
        crawl=null;
	    if (config!=null)
            config.dispose();
        config=null;
    }

    public void create() {
        config = new Config(configFile).create();
        crawl = new Crawl(config);
        crawl.create();
    }

    protected static int help() {
        String usage = "\n" 
               + "   -crawl [directories|oai] to storage\n"
               + "          -probe check setup\n"
               + "          -test [directory] test files\n"
               + "          -dump [resource] out of store\n"
               + "          -post [resource] rdf file to storage\n"
               + "          -del [resource] delete from storage\n"
               + "          -destroy : destroy storage.\n"
			   + "\n";
        System.out.print(usage);
        return 0;
    }

    public static void main(String[] args) {
        if (args.length==0) {
            org.shanghai.rdf.Main.help();
            return;
        }

        if (args[0].startsWith("-conf")) {
            if (1<args.length) {
                configFile = args[1];
                args = Config.shorter(Config.shorter(args));
            } else {
                Config config = new Config(configFile).create();
                config.test();
            }
        }

        if (args[0].startsWith("-index")) {
            Config config = new Config(configFile).create();
            Indexer indexer;
            if (args.length>1&&args[1].startsWith("index")) {
                indexer = new Indexer(config,args[1]);
                args = Config.shorter(args);
            } else {
                indexer = new Indexer(config);
            }
            indexer.create();
            if (args.length==1) {
                indexer.index();
            } else if (args.length==2) {
                if (args[1].equals("-probe")) {
                    indexer.probe();
                } else if (args[1].equals("-test")) {
                    indexer.test();
                } else if (args[1].equals("-dump")) {
                    indexer.dump();
                } else if (args[1].equals("-clean")) {
                    indexer.clean();
                } else if (args[1].equals("-destroy")) {
                    indexer.clean();
                }
            } else if (args.length==3) {
                if (args[1].equals("-test")) {
                    indexer.test(args[2]);
                } else if (args[1].equals("-dump")) {
                    indexer.dump(args[2]);
                } else if (args[1].equals("-post")) {
                    indexer.post(args[2]);
                } else if (args[1].equals("-del")) {
                    indexer.remove(args[2]);
                } else { // index from to
                    indexer.index(args[1],args[2]);
                }
            } else if (args.length==4) {
                if (args[1].equals("-dump")) {
                    indexer.dump(args[2],args[3]);
                }
            }
            indexer.dispose();
            return;
        }

        if (args[0].startsWith("-urn")) {
            Config config = new Config(configFile).create();
            URN engine = new URN(config.get("oai.urnPrefix"));
            if (args.length==2) {
                engine.create();
                engine.make(args[1]);
                engine.dispose();
            }
            return;
        }

        if (args[0].startsWith("-crawl")) {
            if (args.length==1) {
                help();
            } else if (args.length==2 && args[1].startsWith("-")) {
                Main engine = new Main();
                engine.create();
                if (args[1].equals("-probe")) {
                    engine.crawl.probe();
                } else if (args[1].equals("-test")) {
                    engine.crawl.test(".");
                } else if (args[1].equals("-dump")) {
                    engine.crawl.dump();
                } else if (args[1].equals("-clean")) {
                    engine.crawl.clean();
                } else if (args[1].equals("-destroy")) {
                    engine.crawl.clean();
                }
                engine.dispose();
            } else if (args.length==3 && args[1].startsWith("-")) {
                Main engine = new Main();
                engine.create();
                if (args[1].equals("-dump")) {
                    engine.crawl.dump(args[2]);
                } else if (args[1].equals("-test")) {
                    engine.crawl.test(args[2]);
                } else if (args[1].equals("-post")) {
                    engine.crawl.post(args[2]);
                } else if (args[1].equals("-del")) {
                    engine.crawl.delete(args[2]);
                }
                engine.dispose();
            } else if (args.length==4 && args[1].startsWith("-")) {
                Main engine = new Main();
                engine.create();
                if (args[1].equals("-dump")) {
                    engine.crawl.dump(args[2], args[3]);
                } else if (args[1].equals("-test")) {
                    engine.crawl.test(args[2], args[3]);
                } else {
                    engine.crawl.crawl(args);
                }
                engine.dispose();
            } else {
                Main engine = new Main();
                engine.create();
                engine.crawl.crawl(args);
                engine.dispose();
            }
        }
    }
}
