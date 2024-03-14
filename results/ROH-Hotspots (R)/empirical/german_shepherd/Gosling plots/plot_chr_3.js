const current_chromosome = "Chromosome 3"
const url_roh_segments_file = "http://127.0.0.1:5500/ROH-Frequency%20per%20chromosome/chr3_threshold_0.753086_ROH_data.tsv"
const url_ROH_hotspots = "http://127.0.0.1:5500/ROH-hotspots/chr3_ROH_hotspot_data_split.tsv"
const plot_title = current_chromosome +" - ROH-Hotspot 75 % Cutoff"

const background_color="grey"
// const background_color="white"
const background_opacity = 0.1
// const background_color="black"

// const y_domain_value = [0,300] // y_column = "Count"
const y_domain_value = [0,1] // y_column = "Frequency"
// const y_column = "Count"
const y_column = "FREQUENCY"


const color_ROH_threshold = "green"
// const value_ROH_threshold = 230 // y_column = "Count"
const value_ROH_threshold = 0.753086 // y_column = "Frequency"

const marker_size_ROH_threshold = 1


// "mark": "point",
const mark_var = "point"
// const mark_var = "line"
// const mark_var = "bar"
const marker_size = 1 // Good for bar-plot
// const marker_size = 0.5 // Good for bar-plot
const segment_color = "black"
// const segment_color = "white"
const opacity_color = 1


const mark_var_ROH_hotspot = "point"
// const mark_var_ROH_hotspot = "bar"
// const mark_var_ROH_hotspot = "line"
// const marker_size_ROH_hotspot = 8 // good for bar-plot
const marker_size_ROH_hotspot = 3
const color_ROH_hotspot = "cyan"
const opacity_color_ROH_hotspot = 1




// Define the data tracks
var plot_spec = {
    "title":plot_title ,
    "static": false,
    "xDomain": {
        "interval": [
            1,
            91900000
        ]
    },
    "alignment": "overlay",
    "width": 1100,
    "height": 300,
    "assembly": "unknown",
    "style": {
        "background": background_color,
        "backgroundOpacity": background_opacity
    },
    "tracks": [
        {


            
            "data": {
                "url": url_roh_segments_file,
                "type": "csv",
                "separator": "\t",
                "column": "POS",
                "value": y_column,
                // "binSize": 10,
                // "sampleLength": "5000"
            },
            "mark": mark_var,
            "x": {
                "field": "POS",
                "type": "genomic",
                "axis": "bottom"
            },
            "y": {
                "field": y_column,
                "type": "quantitative",
                "axis": "left",
                "domain": y_domain_value,
                // "baseline": "2"
            },
            "color": {
                "value": segment_color
            },
            "opacity": {
                "value": opacity_color
            },
            "size": {
                "value": marker_size
            },
            "tooltip": [
                {
                    "field": "COUNT",
                    "type": "quantitative",
                    "format": "0.0f",
                    "alt": "Count"
                },
                {
                    "field": "POS",
                    "type": "genomic",
                    "format": "0.2f",
                    "alt": "POS"
                }
            ]
        },
        {
            "data": {
                "type": "json",
                "values": [
                //   {"c": "chr3", "p": 100000, "v": 0.0001},
                  {"p": 1, "v": value_ROH_threshold}

                ],
                // "chromosomeField": "c",
                "genomicFields": ["p"]
              },
              "mark": "rule",
              "x": {"field": "p", "type": "genomic"},
            //   "y": {"value":200,"type": "quantitative"},
            // "y": {"field": "v", "type": "quantitative","domain": [200,200]},
            "y": {"field": "v", "type": "quantitative","domain": y_domain_value},



            //   "y": {"field": "v", "type": "quantitative", "domain": [100,200]},
            // "strokeWidth": {"type": "quantitative"},

              "strokeWidth": {"field": "p", "type": "quantitative","value":marker_size_ROH_threshold},
              "color": {"value": color_ROH_threshold},
              "size": {"value": marker_size_ROH_threshold}

            }
,
        {
            "data": {
                "url": url_ROH_hotspots,
                "type": "csv",
                "separator": "\t",
                "column": "POS",
                "value": y_column,
                // "binSize": 10,
                // "sampleLength": 1000
            },
            "mark": mark_var_ROH_hotspot,
            "x": {
                "field": "POS",
                "type": "genomic",
                "axis": "bottom"
            },
            "y": {
                "field": y_column,
                "type": "quantitative",
                "axis": "left",
                "domain": y_domain_value,
                // "baseline": "2"
            },
            "color": {
                "value": color_ROH_hotspot
            },
            "opacity": {
                "value": opacity_color_ROH_hotspot
            },
            "size": {
                "value": marker_size_ROH_hotspot
            },
            "tooltip": [
                {
                    "field": "COUNT",
                    "type": "quantitative",
                    "format": "0.0f",
                    "alt": "ROH-Hotspot: Count"
                },

                {
                    "field": "FREQUENCY",
                    "type": "quantitative",
                    "format": "0.3f",
                    "alt": "ROH-Hotspot: Frequency"
                },

                {
                    "field": "Length_kb",
                    "type": "quantitative",
                    "format": "0.0f",
                    "alt": "ROH-Hotspot: Hotspot length (Kb)"
                },


                {
                    "field": "Hotspot_interval",
                    "type": "nominal",
                    "format": "0.3f",
                    "alt": "ROH-Hotspot: Hotspot window (bp)"
                },





                {
                    "field": "POS",
                    "type": "genomic",
                    "format": "0.2f",
                    "alt": "ROH-Hotspot: Pos (bp)"
                }
            ]
        }

        ]                
};

export { plot_spec };