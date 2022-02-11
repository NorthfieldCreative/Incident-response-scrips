import re
textfile = open("test.txt", "r")
regex = re.compile(r'<ns2:violationtext>(.+?)</ns2:violationtext>')
for line in textfile:
    results = regex.findall(line)
    for word in results:
        print(word)
        file= open("output.txt", "w+")
        file.write(word)
        file.close()
#matches = []
#offset = 0 


#reg = re.compile("<ns2:violationtext>(.+?)</ns2:violationtext>")
#for line in textfile:
#	matches += [(reg.findall(line),offset)]
#	offset += len(line)
#textfile.close

#######creating a config file and saving the input data with each attribute on a new line
#                                    file= open("config", "w+")
 #                                   file.write(filename + "\n")