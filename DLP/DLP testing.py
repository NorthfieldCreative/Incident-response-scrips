import requests
import shutil
import os
import subprocess, sys
import re
import smtplib
import mimetypes
from email.mime.multipart import MIMEMultipart
from email import encoders
from email.message import Message
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase
from email.mime.image import MIMEImage
from email.mime.text import MIMEText
import datetime
now = datetime.datetime.now()
datestring = now.strftime('%m-%d-%y')
addencrypted = "[nylsecured]"
print("\n\n\n\n\n\n\n\n\n\n\n")
print("**********************************************************************")
print("*                                                                    *")
print("*                                                                    *")
print("*                                                                    *")
print("*                                                                    *")
print("*                 D D        L             P P P                     *")
print("*                 D   D      L             P    P                    *")
print("*                 D    D     L             P P P                     *")
print("*                 D    D     L             P                         *")
print("*                 D   D      L             P                         *")
print("*                 D D        L L L L       P                         *")
print("*                                                                    *")
print("*                                                                    *")
print("*                                                                    *")
print("*                 Automated Testing & Audit Tool                     *")
print("*                                                                    *")
print("*                                                                    *")
print("*                                                                    *")
print("**********************************************************************")



####creating a null variable in case no config file exists. Allows passing through the 'if' check
useconfig = ""







################################################################
#Have they tested and saved their settings before? Checking.....
################################################################

if (os.path.exists('config')) == True:
######If they would like to re-use settings, then loading them from file and assigning to variables
    filename = open("config", "r").read().splitlines()[0]
    driveletter = open("config", "r").read().splitlines()[1]
    sender = open("config", "r").read().splitlines()[2]
    recipient = open("config", "r").read().splitlines()[3]
    smtpserver = open("config", "r").read().splitlines()[4]
    rs = open("config", "r").read().splitlines()[5]
    usesmtp = open("config", "r").read().splitlines()[6]
    usehttp = open("config", "r").read().splitlines()[7]
    automated = open("config", "r").read().splitlines()[8]
    secondsender = open("config", "r").read().splitlines()[9]
        
        
        #################################################################################################
        #################################################################################################
        #################################################################################################
        #################################################################################################
        #######                         AUTOMATING ALL THE TESTS                        #################
        #################################################################################################
        #################################################################################################
        #################################################################################################
        #################################################################################################
        
        
        
        
        
        
        
        
                ##############################################################################################################################################
                #           NON ENCRYPTED EMAIL FROM SENDER 1
                ###############################################################################################################################################
if automated == "y":
    if usesmtp == "y":     
        emailfrom = sender
        emailto = recipient
        fileToSend = filename
        msg = MIMEMultipart()
        msg["From"] = emailfrom
        msg["To"] = emailto
        #testencrypted = input("\n\nTest encrypted email using the [nylsecured] subject tag? (y or n)")
        #while not re.match("y|n$", testencrypted):
        #    testencrypted = input("ERROR: Please enter only 'y' or 'n'. Would you like to test encrypted email using the [nylsecured] subject tag? (y or n)")               
        #if testencrypted == "y":
        #    msg["Subject"] = "Policy assurance testing " + datestring + addencrypted
        #else:
        msg["Subject"] = "Policy assurance testing " + datestring
            #msg.preamble = "TEST I cannot send an attachment to save my life"
        body = "This is an automated testing and audit incident"
        body = MIMEText(body)
        msg.attach(body)
        #msg.set_content("This is a test for the body")
        ctype, encoding = mimetypes.guess_type(fileToSend)
        if ctype is None or encoding is not None:
            ctype = "application/octet-stream"
        maintype, subtype = ctype.split("/", 1)
        if maintype == "text":
            fp = open(fileToSend)
            # Note: we should handle calculating the charset
            attachment = MIMEText(fp.read(), _subtype=subtype)
            fp.close()
        elif maintype == "image":
            fp = open(fileToSend, "rb")
            attachment = MIMEImage(fp.read(), _subtype=subtype)
            fp.close()
        elif maintype == "audio":
            fp = open(fileToSend, "rb")
            attachment = MIMEAudio(fp.read(), _subtype=subtype)
            fp.close()
        else:
            fp = open(fileToSend, "rb")
            attachment = MIMEBase(maintype, subtype)
            attachment.set_payload(fp.read())
            fp.close()
            encoders.encode_base64(attachment)
        attachment.add_header("Content-Disposition", "attachment", filename=fileToSend)
        msg.attach(attachment)
        server = smtplib.SMTP(smtpserver)
        server.sendmail(emailfrom, emailto, msg.as_string())
        server.quit()








          
          
          
          
          
          
     
                
                
                
                ##############################################################################################################################################
                #           HTTP POST
                ###############################################################################################################################################
                
                
    if usehttp == "y":
        print("Testing HTTP POST..............")
        #####Sends an HTTP POST using the referenced file as source data to dlptest.com
        with open(filename, 'rb') as f:
            r = requests.post('http://dlptest.com/http-post/', files={filename: f})
        print("Complete")
                
                
                
                ##############################################################################################################################################
                #           REMOVABLE STORAGE
                ###############################################################################################################################################
    if rs == "y":
        print("Testing removable storage...........")
        ######Copies the file to be tested to the root of the specified drive
        testpath = driveletter + ':/' + filename
        shutil.copy2(filename, testpath)
        #######Deletes the copied file and generated powershell script
        os.remove(testpath)
        print("Complete")
    #print("All tests completed!")
    print("All tests completed @ ", now, "!")
elif automated != "y":





    ########################################################################################################################################################
    ########################################################################################################################################################
    ########################################################################################################################################################
    ########################################################################################################################################################
    #                                                                                                                                                      #
    #                                                                                                                                                      #
    #                               IF THE TEST IS NOT BEING AUTOMATED, THEN THE BELOW CODE EXECUTES                                                       #
    #                                                                                                                                                      #
    #                                                                                                                                                      #
    ########################################################################################################################################################
    ########################################################################################################################################################
    ########################################################################################################################################################
    ######################################################################################################################################################## 







    #############################################
    ######Would they like to re-user their settings?
    #############################################
    
    useconfig = input("\n\nIt looks like you have saved settings from your last test. Would you like to re-use them? (y or n)")
    
    #############################################
    ######Making sure they enter Y or N
    #############################################
    while not re.match("y|n$", useconfig):
        useconfig = input("ERROR: Please enter only 'y' or 'n'. It looks like you have saved settings from your last test. Would you like to re-use them? (y or n)")
    
    
    
    
    
    
    
    #############################################
    ######if no config file, or input is needed, collecting it now
    #############################################
    if useconfig != "y":
                    rs = input("\n\nWould you like to test removable storage? (y or n)")
                    while not re.match("y|n$", rs):
                                    rs = input("ERROR: Please enter only 'y' or 'n'. Would you like to test removable storage? (y or n)")
                    usesmtp = input("\n\nWould you like to test email? (y or n)")
                    while not re.match("y|n$", usesmtp):
                                    usesmtp = input("ERROR: Please enter only 'y' or 'n'. Would you like to test email? (y or n)")
                    usehttp = input("\n\nWould you like to test HTTP? (y or n)")
                    while not re.match("y|n$", usehttp):
                                    usehttp = input("ERROR: Please enter only 'y' or 'n'. Would you like to test HTTP? (y or n)")
                    
                    if rs == "y":
                        print("\n\nBe sure your removable storage device is in place and ready for testing!")
                    filename = input("Enter the file with its extension that you wish to use for testing: ")
                    
                    if rs == "y":
                        driveletter = input("\n\nEnter the drive letter (ONLY) of your removable storage device: ")
                    else:
                        driveletter = "C"
                    ####ensuring that only a single drive letter is input (regex)
                    while not re.match("\w{1}$", driveletter):
                                    driveletter = input("ERROR: Only *one* letter may be input. Enter the drive letter (ONLY) of your removable storage device: ")
                    sender = input("\n\nEnter your email address: ")
                    recipient = input("Enter a recipient address (Be sure to always use the same recipient address for audit purposes: ")
                    smtpserver = input("Enter your SMTP server's IP address: ")
                    saved = input("\n\nWould you like to save this data to make future testing faster (y or n)")
                    ######asking if they'd like to speed up the process in the future by saving their input
                    while not re.match("y|n$", saved):
                                    saved = input("ERROR: Please enter only 'y' or 'n'. Would you like to save this data to make future testing faster (y or n)")
                    if saved == "y":
                                    #######creating a config file and saving the input data with each attribute on a new line
                                    file= open("config", "w+")
                                    file.write(filename + "\n")
                                    file.write(driveletter + "\n")
                                    file.write(sender + "\n")
                                    file.write(recipient + "\n")
                                    file.write(smtpserver + "\n")
                                    file.write(rs + "\n")
                                    file.write(usesmtp + "\n")
                                    file.write(usehttp + "\n")
                                    file.close() 
                    
                    
                    
                    
                    
                    
                    
                    #############################################
                    #############################################
                    #############################################
                    #############################################
                    #############################################
                    #############################################
                    #############################################
                    #############################################
                    #             Starting the actual testing  #
                    #############################################
                    #############################################
                    #############################################
                    #############################################
                    
                    
                    
                    
                    
                    
                    #############################################
                    #           EMAIL
                    ##############################################
    if usesmtp == "y":     

                    emailfrom = sender
                    emailto = recipient
                    fileToSend = filename

                    msg = MIMEMultipart()
                    msg["From"] = emailfrom
                    msg["To"] = emailto
                    
                    
                    
                    testencrypted = input("\n\nTest encrypted email using the [nylsecured] subject tag? (y or n)")
                    while not re.match("y|n$", testencrypted):
                                        testencrypted = input("ERROR: Please enter only 'y' or 'n'. Would you like to test encrypted email using the [nylsecured] subject tag? (y or n)")               
                    if testencrypted == "y":
                        msg["Subject"] = "Policy assurance testing " + datestring + addencrypted
                    else:
                        msg["Subject"] = "Policy assurance testing " + datestring
                  
                    #msg.preamble = "TEST I cannot send an attachment to save my life"
                    body = "This is an automated testing and audit incident"
                    body = MIMEText(body)
                    msg.attach(body)
                    #msg.set_content("This is a test for the body")
                    ctype, encoding = mimetypes.guess_type(fileToSend)
                    if ctype is None or encoding is not None:
                        ctype = "application/octet-stream"

                    maintype, subtype = ctype.split("/", 1)

                    if maintype == "text":
                        fp = open(fileToSend)
                        # Note: we should handle calculating the charset
                        attachment = MIMEText(fp.read(), _subtype=subtype)
                        fp.close()
                    elif maintype == "image":
                        fp = open(fileToSend, "rb")
                        attachment = MIMEImage(fp.read(), _subtype=subtype)
                        fp.close()
                    elif maintype == "audio":
                        fp = open(fileToSend, "rb")
                        attachment = MIMEAudio(fp.read(), _subtype=subtype)
                        fp.close()
                    else:
                        fp = open(fileToSend, "rb")
                        attachment = MIMEBase(maintype, subtype)
                        attachment.set_payload(fp.read())
                        fp.close()
                        encoders.encode_base64(attachment)
                    attachment.add_header("Content-Disposition", "attachment", filename=fileToSend)
                    msg.attach(attachment)

                    server = smtplib.SMTP(smtpserver)
                    server.sendmail(emailfrom, emailto, msg.as_string())
                    server.quit()          




                    #############################################
                    #############################################
                    #           HTTP POST
                    ##############################################
                    #############################################
    if usehttp == "y":
                    print("Testing HTTP POST..............")
                    #####Sends an HTTP POST using the referenced file as source data to dlptest.com
                    with open(filename, 'rb') as f:
                        r = requests.post('http://dlptest.com/http-post/', files={filename: f})
                    print("Complete")
                    
                    
                    
                    
                   ############################################# 
                    #############################################
                    #           REMOVABLE STORAGE
                    ##############################################
                    #############################################
    if rs == "y":
                    print("Testing removable storage...........")
                    ######Copies the file to be tested to the root of the specified drive
                    testpath = driveletter + ':/' + filename
                    shutil.copy2(filename, testpath)
                    #######Deletes the copied file and generated powershell script
                    os.remove(testpath)
                    print("Complete")
    
    
    print("All tests completed @ ", datetime.now(), "!")
