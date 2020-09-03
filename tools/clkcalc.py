import sys;

base_freq = float(sys.argv[1])
target_freq = float(sys.argv[2])


best_m=-1
best_d=-1
best_freq=0

for m in range(1,33):
	for d in range (1,33):
		new_freq = base_freq * m / d

		if best_freq==0 or abs(new_freq - target_freq) < abs(best_freq - target_freq):
			best_freq = new_freq
			best_m = m
			best_d = d


print
print "Best: %f * %i / %i = %f" % (base_freq, best_m, best_d, best_freq)
