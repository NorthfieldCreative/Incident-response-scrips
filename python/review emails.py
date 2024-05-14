import win32com.client

def process_folder(folder):
    messages = folder.Items
    messages.Sort("[ReceivedTime]", True)  # Sort by received time, True for descending order

    sender_email = "ryanri@shure.com"  # Replace with the specific sender email address

    for message in messages:
        try:
            if message.SenderEmailAddress and message.SenderEmailAddress.lower() == sender_email.lower():
                print("Subject:", message.Subject)
                print("Sender:", message.SenderName)
                print()
        except AttributeError:
            continue

    for subfolder in folder.Folders:
        process_folder(subfolder)

outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")
root_folder = outlook.Folders.Item(1)  # Access the root folder, change the index as needed

process_folder(root_folder)