clnms = int(input())
lstnms = []
for _ in range(clnms):
    nms = int(input())
    if str(nms)[-1] == "4":
        lstnms.append(nms)
print(min(lstnms)) 
