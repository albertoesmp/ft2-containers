import result
import numpy as np
import matplotlib.pyplot as plt
import os

# ---  ANALYZER CLASS  --- #
# ------------------------ #
class Analyzer:
    # ---  OVERRIDES  --- #
    # ------------------- #
    def __init__(self, results, output_path):
        """
        Build an Analyzer instance
        :param results: List of Results items
        """
        self.results = results
        self.output_path = output_path

    # --- CLASS METHODS --- #
    # --------------------- #
    @classmethod
    def parse_config_file(cls, cfg_file):
        """
        Parses config file, which structure is as follows:
            N
            linpack output name 1
            linpack output path 1
            linpack output name 2
            linpack output path 2
            ...
            linpack output name N
            linpack output path N
            analyzer output directory path
        :param cfg_file: Path to the config file to be parsed
        :return: (linpack_output_names, linpack_output_paths, analyzer_output_path)
        """
        linpack_output_names = []
        linpack_output_paths = []
        with open(cfg_file) as cfg:
            n = int(cfg.readline())
            for i in range(n):
                name = cfg.readline()
                path = cfg.readline()
                linpack_output_names.append(name)
                linpack_output_paths.append(path)
            analyzer_output_path = cfg.readline().rstrip()

        return linpack_output_names, linpack_output_paths, analyzer_output_path

    @classmethod
    def from_config_file(cls, cfg_file):
        """
        Build an Analyzer from a config file
        :param cfg_file: Path to the config file used to build Analyzer
        :return: Analyzer built considering cfg_file
        """
        linpack_output_names, linpack_output_paths, analyzer_output_path = \
            cls.parse_config_file(cfg_file)
        results = []
        for i in range(len(linpack_output_paths)):
            name = linpack_output_names[i].rstrip()
            path = linpack_output_paths[i].rstrip()
            results.append(result.Result.from_linpack_output(name,path))
        return Analyzer(results, analyzer_output_path)

    # --- MEMBER METHODS --- #
    # ---------------------- #
    def analyze(self):
        """
        Prints an analysis for each result known by the analyzer
        :return: No return
        """
        for r in self.results:
            print('Result {name}: '.format(name=r.name))
            print('\tMin gflops record -> {record}'.format(
                record=r.get_min_gflops_record()))
            print('\tMax gflops record -> {record}'.format(
                record=r.get_max_gflops_record()))
            print('\tMean gflops value -> {value}'.format(
                value=r.get_average_gflops()))
            print('\tStd_dev gflops value -> {value}'.format(
                value=r.get_std_deviation_gflops()))
        return self

    def barchart_log(self,
                 colors=(
                     (1.0,0.3,0.3),
                     (0.3,0.75,0.2),
                     (0.2,0.4,0.8),
                     (0.8,0.6,0.3),
                     (0.75,0.3,0.8)
                 ),
                 output_prefix=None
                 ):
        """
        Plot comparison using a bar chart in logarithmic scale
        :param colors: Colors to be used for each bar.
            If there are more bars than colors then this parameter
            is used in a cyclic fashion.
        :param output_prefix: Path to directory where plots are
            exported.
        :return: The analyzer itself.
        """
        # Extract results of interest
        names = [] # Name for each result
        _mins = [] # Min gflops record for each result
        _maxs = [] # Max gflops record for each result
        _avgs = [] # Average gflops record for each result
        for r in self.results:
            names.append(r.name)
            _mins.append(r.get_min_gflops_record())
            _maxs.append(r.get_max_gflops_record())
            _avgs.append([r.get_average_gflops() for i in range(r.get_num_fields())])
            _avgs[-1][0] = 'AVERAGE'
            _avgs[-1][2] = '-AVG'
            _avgs[-1][3] = 'P'
            _avgs[-1][4] = 'Q'
        # Simple vars pointing to results of interest
        iterable_y = [_mins, _avgs, _maxs]

        # Make barchart
        fig, ax = plt.subplots()
        ind = np.arange(3) # 3 -> min, max, mean
        width = 0.90 # Width for each set of bar (not for each bar)
        bars_sets = []
        for i in range(len(self.results)):
            shift = ind + i*width/len(self.results)
            vals = [_mins[i][-1], _avgs[i][-1], _maxs[i][-1]]
            bars = ax.bar(
                        shift, vals, width/len(self.results),
                        label=names[i],
                        color=colors[i%len(colors)], linewidth=1.0,
                        edgecolor=[0.1,0.1,0.1]
                    )
            for j in range(len(ind)):
                text = '{TV} {P}x{Q} NB{NB:3} {gflops:7.5} GFLOPS'.format(
                    TV=iterable_y[j][i] if type(iterable_y[j][i]) is str \
                        else iterable_y[j][i][0],
                    P=iterable_y[j][i] if type(iterable_y[j][i]) is float \
                        else iterable_y[j][i][3],
                    Q=iterable_y[j][i] if type(iterable_y[j][i]) is float \
                        else iterable_y[j][i][4],
                    NB=iterable_y[j][i] if type(iterable_y[j][i]) is float \
                        else iterable_y[j][i][2],
                    gflops=iterable_y[j][i] if type(iterable_y[j][i]) is float \
                        else iterable_y[j][i][-1]
                )

                ax.text(
                    bars[j].get_x() + bars[j].get_width()*0.5 - 0.02,
                    max([m[-1] for m in _maxs])/4,
                    text,
                    rotation=90,
                    weight='bold',
                )

            bars_sets.append(bars)


        ax.set_ylabel('GFLOPS')
        ax.set_title('LINPACK GFLOPS')
        ax.set_xticks(ind+width/len(names)*len(names)/2-width/2/len(names))
        ax.set_xticklabels(('min', 'mean', 'max'))
        ax.set_yscale('log')
        ax.legend()
        ax.grid(True, which='major', axis='y',
                color=[0.5,0.5,0.5], linestyle='--')


        #plt.show() # Toggle/Untoggle to view plot during runtime or not
        if self.output_path is not None:
            if not os.path.exists(self.output_path):
                os.makedirs(self.output_path)
            fig.savefig(
                os.path.join(self.output_path, "logarithmic.png"),
                dpi=142,
                quality=95,
                format="png"
            )
        return self

    def barchart_lin(self,
                     colors=(
                             (1.0,0.3,0.3),
                             (0.3,0.75,0.2),
                             (0.2,0.4,0.8),
                             (0.8,0.6,0.3),
                             (0.75,0.3,0.8)
                     ),
                     output_prefix=None
                     ):
        """
        Plot comparison using a bar chart in linear scale
        :param colors: Colors to be used for each bar.
            If there are more bars than colors then this parameter
            is used in a cyclic fashion.
        :param output_prefix: Path to directory where plots are
            exported.
        :return: The analyzer itself.
        """
        # Extract results of interest
        names = [] # Name for each result
        _maxs = [] # Max gflops record for each result
        for r in self.results:
            names.append(r.name)
            _maxs.append(r.get_max_gflops_record())
        # Simple vars pointing to results of interest
        iterable_y = [_maxs]

        # Make barchart
        fig, ax = plt.subplots()
        ind = np.arange(1) # 1 -> max
        width = 0.90 # Width for each set of bar (not for each bar)
        bars_sets = []
        for i in range(len(self.results)):
            shift = ind + i*width/(len(self.results)-1)
            vals = [_maxs[i][-1]]
            bars = ax.bar(
                shift, vals, width/len(self.results),
                label=names[i],
                color=colors[i%len(colors)], linewidth=1.0,
                edgecolor=[0.1,0.1,0.1]
            )
            for j in range(len(ind)):
                text = '{gflops:7.5} GFLOPS'.format(
                    gflops=iterable_y[j][i] if type(iterable_y[j][i]) is float \
                        else iterable_y[j][i][-1]
                )

                ax.text(
                    bars[j].get_x(),
                    max([m[-1] for m in _maxs])/1.5,
                    text,
                    rotation=0,
                    weight='bold',
                    fontsize=8
                )

            bars_sets.append(bars)


        ax.set_ylabel('GFLOPS')
        ax.set_title('LINPACK BEST GFLOPS')
        ax.get_xaxis().set_visible(False)
        ax.set_yscale('linear')
        ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.03), shadow=True, ncol=len(self.results))
        ax.grid(True, which='major', axis='y',
                color=[0.5,0.5,0.5], linestyle='--')


        #plt.show() # Toggle/Untoggle to view plot during runtime or not
        if self.output_path is not None:
            if not os.path.exists(self.output_path):
                os.makedirs(self.output_path)
            fig.savefig(
                os.path.join(self.output_path, "linear.png"),
                dpi=142,
                quality=95,
                format="png"
            )
        return self
