from __future__ import print_function
import datetime
import sys

"""
(Python 2.7/3.6 compatible)
Takes result of `git --no-pager log`
and tallies the amount of commits on each day
and them it to a file called .LAST_COMMIT_HISTORY.txt
in the format `YYYY-MM-DD COUNT`.
"""

months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
dates = []
history = {}

for line in sys.stdin:
    if "Date" in line:
        s = line.strip().split()
        dates.append(datetime.date(int(s[-2]), int(months.index(s[2])+1), int(s[3])))
        
for x in range((dates[0]-dates[-1]).days + 1):
    day = dates[-1]
    day += datetime.timedelta(days=x)
    if day in dates:
        days = list(filter(lambda x: x==day, dates))
        history[day] = len(days)
    else:
        history[day] = 0

with open(".LAST_COMMIT_HISTORY.txt", "w") as f:   
    f.writelines([" ".join([str(d), str(history[d])]) + "\n" for d in sorted(history.keys())])

