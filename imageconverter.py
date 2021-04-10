from PIL import Image
import webcolors
import sys

def xy_to_frame_buffer(x,y):
    return (y*32 + x)*4

def main():
    im = Image.open(sys.argv[1])
    sx, sy = im.size

    count = 0
    # Create a list of colors excluding black
    coloursList = [];

    # loop through pixels of the image and find the colours
    for j in range(sy):
        for i in range(sx):
            count += 1
            px = im.getpixel((i,j))
            px = (px[0],px[1],px[2])
            if px != (0,0,0) and (px not in coloursList):
                coloursList.append(px)
            #print(f"The pixel value at ({i},{j}) is {px}")
    print(f"Counted {count} pixels and {len(coloursList)} colours")
    print("==================PRINTING OUTPUT BELOW==================")
    print("        la $t0, BASE_ADDRESS")
    # print the colours to the registers
    for i in range(len(coloursList)):
        stuff = webcolors.rgb_to_hex(coloursList[i]).replace("#", "0x")
        print(f"        li $t{i+1}, {stuff}")

    # print the location to the images
    for j in range(sy):
        for i in range(sx):
            px = im.getpixel((i,j))
            px = (px[0],px[1],px[2])

            if px != (0,0,0):
                print(f"        sw $t{coloursList.index(px)+1}, {xy_to_frame_buffer(i,j)}($t0)")
    print("jr $ra")

    print("==================END OF OUTPUT==========================")

if __name__ == "__main__":
    main()