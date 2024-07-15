import os 
import re
blocks = []
resources = []
files = os.listdir("./")
for file in files:
    if (os.path.isdir("./"+file)):
        content = open("./"+file+"/"+file+".tres","rt").read()
        info = re.search(r"(?<=\[gd_resource type=\")(.*?)(?=\").*(?<=uid=\")(.*?)(?=\")", content)
        string = "[ext_resource type=\"" + info[1] + "\" uid=\"" + info[2] + "\" path=\"res://blocks/" + file + "/" + file + ".tres\" id=\"" + info[2].removeprefix("uid://") + "\"]"
        blocks.append([file, info[2].removeprefix("uid://")])
        resources.append(string)

lib = open("./blocks.lib.tres", "rt")
before = re.search(r"\[gd_resource.*?]", lib.read().split("[resource]")[0])[0]

# PlaceholderMesh = re.search("(?<=\[sub_resource type=\"PlaceholderMesh\" id=\").*(?=\"])", "[sub_resource type=\"PlaceholderMesh\" id=\"PlaceholderMesh_1r05a\"]")
# print(PlaceholderMesh)
mesh = "mesh = SubResource(\"PlaceholderMesh_1r05a\")"
# mesh = "mesh = SubResource(\"" + PlaceholderMesh + "\")"
mesh_transform = "mesh_transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)"
shapes = "shapes = []"
navigation_mesh_transform = "navigation_mesh_transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)"
navigation_layers ="navigation_layers = 1"

toWrite = before 

for r in resources:
    toWrite += "\n" + r

toWrite += "\n[resource]"

i = 0
for block in blocks:
    item = "\nitem/" + str(i) + "/"
    string = item + "name = \"" + block[0] + "\""
    string += item + "mesh = ExtResource(\"" + block[1] + "\")"
    string += item + mesh_transform
    string += item + shapes
    string += item + navigation_mesh_transform
    string += item + navigation_layers
    
    i += 1

    toWrite += string

# print(before)
def confirm():
    inData = input("are you shure you want to override the block lib file? (Y/N)")
    if (inData in ["Y","y"] ):
        open("./blocks.lib.tres", "wt").write(toWrite)
    elif (inData in ["N","n"]):
        pass
    else: confirm()

confirm()