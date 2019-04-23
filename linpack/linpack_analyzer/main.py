import analyzer
import sys

# ---  M A I N  --- #
# ----------------- #
if __name__ == '__main__':
    # Args parsing
    if len(sys.argv) != 2:
        print(
                'You  have to provide parameters as follow:'
                '\t{bin} AnalyzerConfigFile'
                .format(
                    bin=sys.argv[0]
                )
        )

    cfg_file = sys.argv[1]

    # Analysis
    analyzer.Analyzer.from_config_file(cfg_file)\
        .analyze()\
        .barchart_log()\
        .barchart_lin()
