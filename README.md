# image_similarity_flutter

This project is the implementation of a deep-ranking based image similarity model into a flutter app prototype. 

## Introduction

The aim is to be able to assert that an image taken by the user belong to the same class as some reference images. As an example, let's say that we have three reference images of the Joconde shot at different angles. We want to be able to:

- take a picture of the Joconde (with different contrasts, shot angles, lighting, etc) and assert that it is indeed the Joconde;
- take a picture of another portrait painting and assert that it is not the Joconde.

The implementation of the deep-ranking image similarity model is based on this [repository]("https://github.com/akarshzingade/image-similarity-deep-ranking"). The weights can be found in this [repository]("https://github.com/USCDataScience/Image-Similarity-Deep-Ranking") (the "deepranking.h5" file).
