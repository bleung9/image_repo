# Image Repo challenge for Winter 2021 Shopify internship

This image repo allows anyone to submit an image to be uploaded to the database. Images in the database can be searched for the following characteristics:

- width
- height
- extension
- text in the image
- find all similar images to an uploaded image (doesn't get saved)

This app uses the _latest_ versions of both Ruby and Rails, Rails 6.0.3.2 and Ruby ruby 2.7.1p83.

See [FEATURES.md](/FEATURES.md) for a more detailed breakdown of features.

### Dependencies

To run this app, the following must be installed. The links will take you to installation instructions for MacOS or Linux.

[Elasticsearch for MacOS](https://www.elastic.co/guide/en/elasticsearch/reference/current/brew.html#brew) or [Elasticsearch for Linux](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html)

[ImageMagick](https://imagemagick.org/script/download.php)

[RTesseract](https://github.com/tesseract-ocr/tesseract/wiki)

[vips](https://github.com/Nakilon/dhash-vips)

### Instructions to install and run app

```
git clone 'https://github.com/bleung9/image_repo.git' bleung9_image_repo
bundle install
yarn install --check-files

```

Inside the app directory:

Set up database with:
```
rake db:create
rake db:migrate
```

A background Elasticsearch server must be running for document indexing to work, and for tests to run. To start the Elasticsearch server:

macOS: `brew services start elastic/tap/elasticsearch-full` or `brew services start elasticsearch`

Linux: `sudo -i service elasticsearch start`

Go to `http://localhost:9200/` to verify that it started successfully. You should see something like this:

```
{
  name: "LAPTOP-OMBO549R",
  cluster_name: "elasticsearch",
  cluster_uuid: "KpkpdgWuTVepsCb9dXh42w",
  version: {
    number: "7.9.0",
    build_flavor: "default",
    build_type: "deb",
    build_hash: "a479a2a7fce0389512d6a9361301708b92dff667",
    build_date: "2020-08-11T21:36:48.204330Z",
    build_snapshot: false,
    lucene_version: "8.6.0",
    minimum_wire_compatibility_version: "6.8.0",
    minimum_index_compatibility_version: "6.0.0-beta1"
  },
  tagline: "You Know, for Search"
}
```

Run the server with `rails s`. Go to `http://localhost:3000/` to run the app.

Open console with `rails c`.

Run all tests with `rspec`
