import statistics


# ---  RESULT CLASS  --- #
# ---------------------- #
class Result:
    """
    Result is a set of records composed of:
        T/V -> Wall time / encoded variant
        N -> Order for coefficient matrix A
        NB -> Partitioning blocking factor
        P -> Number of process rows
        Q -> Number of process columns
        Time -> Time to solve the linear system
        Gflops -> Rate of execution for solving the linear system
    """
    # ---  OVERRIDES  --- #
    # ------------------- #
    def __init__(self, name, tv, n, nb, p, q, time, gflops):
        self.name = name
        self.tv = tv
        self.n = n
        self.nb = nb
        self.p = p
        self.q = q
        self.time = time
        self.gflops = gflops

    # --- CLASS METHODS --- #
    # --------------------- #
    @classmethod
    def from_linpack_output(cls, name, linpack_output):
        """
        Build a Result from a linpack output path
        :param name: Name for the experiment
        :param linpack_output: Path to the linpack output
        :return: Result built considering info at linpack output file
        """
        tv = []
        n = []
        nb = []
        p = []
        q = []
        time = []
        gflops = []
        with open(linpack_output) as lo:
            for line in lo:
                if line.find("WR") != -1:
                    # If it is a result line
                    split = line.split()
                    tv.append(split[0])
                    n.append(int(split[1]))
                    nb.append(int(split[2]))
                    p.append(int(split[3]))
                    q.append(int(split[4]))
                    time.append(float(split[5]))
                    gflops.append(float(split[6]))
        return Result(name, tv, n, nb, p, q, time, gflops)

    # --- MEMBER METHODS --- #
    # ---------------------- #
    def get_num_fields(self):
        """
        Obtain the number of fields considered by the result
        :return: Number of fields
        """
        count = 0
        if self.tv is not None: count += 1
        if self.n is not None: count += 1
        if self.nb is not None: count += 1
        if self.p is not None: count += 1
        if self.q is not None: count += 1
        if self.time is not None: count += 1
        if self.gflops is not None: count += 1
        return count

    def get_min_gflops_record(self):
        """
        Obtain record with min gflops value
        :return: Record with min gflops value
        """
        min_gflops = self.gflops[0]
        min_gflops_index = 0
        for i in range(1,len(self.gflops)):
            gflops = self.gflops[i]
            if gflops < min_gflops:
                min_gflops = gflops
                min_gflops_index = i
        return (self.tv[min_gflops_index], self.n[min_gflops_index],
                self.nb[min_gflops_index], self.p[min_gflops_index],
                self.q[min_gflops_index], self.time[min_gflops_index],
                self.gflops[min_gflops_index])

    def get_max_gflops_record(self):
        """
        Obtain record with max gflops value
        :return: Record with max gflops value
        """
        max_gflops = self.gflops[0]
        max_gflops_index = 0
        for i in range(1,len(self.gflops)):
            gflops = self.gflops[i]
            if gflops > max_gflops:
                max_gflops = gflops
                max_gflops_index = i
        return (self.tv[max_gflops_index], self.n[max_gflops_index],
                self.nb[max_gflops_index], self.p[max_gflops_index],
                self.q[max_gflops_index], self.time[max_gflops_index],
                self.gflops[max_gflops_index])

    def get_average_gflops(self):
        """
        Obtain the average gflops value
        :return: Average gflops value
        """
        return statistics.mean(self.gflops)

    def get_std_deviation_gflops(self):
        """
        Obtian the standard deviation gflops value
        :return: Standard deviation gflops value
        """
        return statistics.stdev(self.gflops)
