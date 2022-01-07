from datetime import datetime
import os
import asyncio
import shutil
from moviepy.editor import *

datetime_format = "%d-%m-%Y_%H:%M:%S:%f"


async def concatenate(videos, outputDir):
    now = datetime.now()
    formattedNow = now.strftime(datetime_format)

    if outputDir == None or len(outputDir) == 0:
        outputDir = "./"
    if not outputDir.endswith("/"):
        outputDir += "/"
    output = outputDir + formattedNow + ".mp4"
    tempDir = formattedNow + "/"

    try:
        os.mkdir(tempDir)
    except Exception:
        print("Folder alread exists")

    tempFiles = []
    for video in videos:
        tempFile = tempDir + str(video.split("/")[-1])
        if not os.path.isfile(tempFile):
            tempCommand = "ffmpeg -n -i " + video + " -c copy " + tempFile
            process = await asyncio.create_subprocess_shell(tempCommand, stdin=asyncio.subprocess.PIPE, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.STDOUT)
            await process.wait()
        tempFiles.append(tempFile)

    clips = []
    for tempFile in tempFiles:
        clips.append(VideoFileClip(tempFile, target_resolution=(720, 1280)))
    final_clip = concatenate_videoclips(clips)
    final_clip.write_videofile(output)

    shutil.rmtree(tempDir)
    cleanup(outputDir)

    return os.path.abspath(output)


def cleanup(dir):
    now = datetime.now()
    for rootDir, _, files in os.walk(dir):
        for file in files:
            try:
                fileDateTime = datetime.strptime(
                    file.split(".")[0], datetime_format)
            except Exception:
                continue
            difference = now - fileDateTime
            differenceInMin = divmod(difference.seconds, 60)[0]
            if differenceInMin > 5:
                try:
                    os.remove(os.path.abspath(os.path.join(rootDir, file)))
                except Exception:
                    continue
