
import win32com.client

outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")
inbox = outlook.GetDefaultFolder(6)
messages = inbox.Items
message = messages.Getlast
body_content = message.body
#print(body_content)
#print(messages)




'''
sender = "my_sender"
sender = sender.lower()
for message in messages:
    if sender in message.sender.lower():
        # This message was send by sender
        print message.body
'''

messages = inbox.Items.Restrict("[SenderEmailAddress]='ryanri@shure.com'")
message = messages.Getlast
body_content = message.body
print(body_content)
#'''