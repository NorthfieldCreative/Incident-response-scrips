from libratom.lib.pff import PffArchive
from email import generator
from pathlib import Path

archive = PffArchive("bill_rapp_000_1_1.pst")
eml_out = Path(Path.cwd() / "emls")

if not eml_out.exists():
  eml_out.mkdir()

print("Writing messages to .eml")
for folder in archive.folders():
    if folder.get_number_of_sub_messages() != 0:
        for message in folder.sub_messages:
            name = message.subject.replace(" ", "_")
            name = name.replace("/","-")
            filename = eml_out / f"{message.identifier}_{name}.eml"
            filename.write_text(archive.format_message(message))
print("Done!")