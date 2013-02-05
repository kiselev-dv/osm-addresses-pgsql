/*************************************
* Simplify streets
* remove points exept first and last
*
* Author dkiselev 
* mailto: dmitry.v.kiselev@gmail.com
**************************************/

#include <stdio.h>
#include "o5mreader.h"

int main(char** argv, int argc) {
    O5mreader* reader;
    O5mreaderDataset ds;
    O5mreaderIterateRet ret, ret2;
    char *key, *val;
    int64_t nodeId;
    int64_t refId;
    uint8_t type;
    char *role;

    if(argc < 2){
	printf("Usage: simlify-streets streets.o5m > streets.osm\n");
	return 1;
    }

    printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    printf("<osm version=\"0.6\" generator=\"simplify-streets\">\n");

    FILE* f = fopen(argv[1],"rb");
    o5mreader_open(&reader, f);
    while( (ret = o5mreader_iterateDataSet(reader, &ds)) == O5MREADER_ITERATE_RET_NEXT ) {
        switch ( ds.type ) {
        // Data set is node
        case O5MREADER_DS_NODE:
            // Could do something with ds.id, ds.lon, ds.lat here, lon and lat are ints in 1E+7 * degree units
            // Node tags iteration, can be omited
            
            float lon = ds.lon / 1e7;
            float lat = ds.lat / 1e7;
            printf("<node id=\"%d\" lon=\"%f\" lat=\"%f\" user=\"fake\" uid=\"1\" visible=\"true\" timestamp=\"2012-07-20T09:43:19Z\">\n", ds.id, lon, lat);
            
            while ( (ret2 = o5mreader_iterateTags(reader,&key,&val)) == O5MREADER_ITERATE_RET_NEXT  ) {
                // Could do something with tag key and val
                printf("<tag k=\"%s\" v=\"%s\" />\n", key, val);
            }
            
            printf("</node>\n");
            break;
        // Data set is way
        case O5MREADER_DS_WAY:
            // Could do something with ds.id
            // Nodes iteration, can be omited
            while ( (ret2 = o5mreader_iterateNds(reader,&nodeId)) == O5MREADER_ITERATE_RET_NEXT  ) {
                // Could do something with nodeId
            }
            // Way taga iteration, can be omited
            while ( (ret2 = o5mreader_iterateTags(reader,&key,&val)) == O5MREADER_ITERATE_RET_NEXT  ) {
                // Could do something with tag key and val
            }
            break;
        // Data set is rel
        case O5MREADER_DS_REL:
            // Could do something with ds.id
            // Refs iteration, can be omited
            while ( (ret2 = o5mreader_iterateRefs(reader,&refId,&type,&role)) == O5MREADER_ITERATE_RET_NEXT  ) {
                // Could do something with refId (way or node or rel id depends on type), type and role
            }
            // Relation tags iteration, can be omited
            while ( (ret2 = o5mreader_iterateTags(reader,&key,&val)) == O5MREADER_ITERATE_RET_NEXT  ) {
                // Could do something with tag key and val
            }
            break;
        }
    }
    
    printf("</osm>");

    fclose(f);
    return 0;
}
