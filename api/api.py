import os
import flask
from flask import jsonify
from flask import request
import translator
import video_editor

app = flask.Flask(__name__)


@app.route("/api", methods=["GET"])
def api():
    ret = {"message": "ASL for All API"}
    return jsonify(ret), 200


@app.route("/api/translate", methods=["GET"])
async def translate():
    if "sentence" in request.args:
        sentence = request.args["sentence"]
        translation = await translator.translate(sentence)

        if translation != None:
            ret = {"translation": translation}
            return jsonify(ret), 200
        else:
            ret = {"error": "Could not translate sentence"}
            return jsonify(ret), 400
    else:
        ret = {"error": "Missing parameters"}
        return jsonify(ret), 400


@app.route("/api/concatenate", methods=["GET"])
async def concatenate():
    if "videos" in request.args:
        video_save_dir = "public/concatenated_videos/"
        video_save_dir_for_url = "concatenated_videos/"

        videos = request.args.getlist("videos")
        concatenated_video = await video_editor.concatenate(videos, video_save_dir)

        if os.path.isfile(concatenated_video):
            url_path = request.url_root + video_save_dir_for_url + \
                concatenated_video.split("/")[-1]
            ret = {"concatenated video": url_path}
            return jsonify(ret), 200
        else:
            ret = {"error": "Could not concatenate videos"}
            return jsonify(ret), 400
    else:
        ret = {"error": "Missing parameters"}
        return jsonify(ret), 400

app.run(host="0.0.0.0")
