import asyncio


async def translate(sentence):
    command = "java -jar api/aslgrammartranslator.jar -i \"" + sentence + "\""
    process = await asyncio.create_subprocess_shell(command, stdin=asyncio.subprocess.PIPE, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.STDOUT)
    await process.wait()
    stdout = await process.communicate()
    result = stdout[0].decode("utf-8")

    if "Translation:\n" in result:
        translation = result[result.index(
            "Translation:\n") + 13:len(result) - 1]
        return translation
    else:
        return None
