# moviesapi

[![Build Status](https://secure.travis-ci.org/nickcharlton/moviesapi.png?branch=master)](http://travis-ci.org/nickcharlton/moviesapi) [![Code Climate](https://codeclimate.com/github/nickcharlton/moviesapi.png)](https://codeclimate.com/github/nickcharlton/moviesapi)

Accessing movie data and up-to-date cinema listings is unreasonably hard.

[Find any Film][] was originally funded by the UK Film Council. In [an article from
way back in 2009][guardian] they describe that an "API will also be rolled out that
will allow developers to build applications around this unique and rich data set".
I guess that never happened, then.

This is a quick-and-dirty API that screenscrapes Find any Film and was
implemented to provide a cinemas and film showings data source for 
[YRS i-DAT's 2013 project][yrs].

It's a simple [Sinatra][] application, using [Nokogiri][] for HTML/XML parsing. It's
very similar to the [UrbanScraper][] API I built previously.

## Usage

The main version is hosted on [Heroku][], so it follows the conventions there. But
to run locally:

```bash
foreman start
```

Go to: http://localhost:4000/.

## License

Copyright (c) 2013 Nick Charlton. Code under the MIT license.

The content is bound by the data source itself and liable to the [Find any Film][]
[Terms and Conditions][]. It basically says that you cannot reuse the data
commercially and you are liable for the dissemination of said data. Or something.

[Find any Film]: http://www.findanyfilm.com
[Terms and Conditions]: http://www.findanyfilm.com/terms-and-conditions
[guardian]: http://www.theguardian.com/media/pda/2009/jan/28/digitalmedia-digitalvideo
[yrs]: https://github.com/yrsIDAT/2013
[Sinatra]: http://www.sinatrarb.com/
[Nokogiri]: http://nokogiri.org/
[UrbanScraper]: https://github.com/nickcharlton/urbanscraper
[Heroku]: http://heroku.com/

