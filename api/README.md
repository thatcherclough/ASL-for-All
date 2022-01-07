# ASL for All API

ASL for All uses a custom python API to translate English grammar to ASL grammar and concatenate videos. All required libraries can be found in 'libs.txt'.Note: aslgrammartranslator.jar must be compiled from [here](https://github.com/thatcherclough/ASLGrammarTranslator).
To run the API, run ``python3 api.py``.

## Open endpoints
Open endpoints require no authentication.

- [Test API](#test-api): ``GET /api``
- [Translate English grammar to ASL grammar](#translate-english-grammar-to-asl-grammar): ``GET /api/translate``
- [Concatenate videos](#concatenate-videos): ``GET /api/concatenate``

## Test API
Used to test if the API is online.

URL: ``/api``

Method: ``GET``

### Success response
Code: ``200``

Content:
```
{
    "message": "ASL for All API"
}
```

## Translate English grammar to ASL grammar
Used to translate English grammar to ASL grammar.

URL: ``/api/translate``

Method: ``GET``

### Parameters
```
{
    "sentence": "[English sentence to translate]"
}
```

### Success response
Code: ``200``

Content example:
```
{
    "translation": "I LOVE MY DOG"
}
```

### Error response
#### Could not translate sentence
Code: ``400``

Content:
```
{
    "error": "Could not translate sentence"
}
```
#### Missing parameters
Code: ``400``

Content:
```
{
    "error": "Missing parameters"
}
```

## Concatenate videos
Used to concatenate videos.

URL: ``/api/concatenate``

Method: ``GET``

### Parameters
```
{
    "videos": "[Array of video URLs]"
}
```

### Success response
Code: ``200``

Content example:
```
{
    "concatenated video": "https://.../video.mp4"
}
```

### Error response
#### Could not concatenate videos
Code: ``400``

Content:
```
{
    "error": "Could not concatenate videos"
}
```
#### Missing parameters
Code: ``400``

Content:
```
{
    "error": "Missing parameters"
}
```

