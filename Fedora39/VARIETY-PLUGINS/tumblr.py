#!/usr/bin/python
# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
### BEGIN LICENSE
# Copyright (c) 2013 Christian Flach
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
### END LICENSE

from variety.Util import Util
from variety.plugins.IQuoteSource import IQuoteSource
from locale import gettext as _

import logging
import random

logger = logging.getLogger("variety")

class TumblrSource(IQuoteSource):
    @classmethod
    def get_info(cls):
        return {
            "name": "Tumblr quotes",
            "description": _("Fetches quotes from tumblrs RSS feed."),
            "author": "Christian Flach",
            "version": "0.1"
        }

    def supports_search(self):
        return True
    
    def get_quote(self, author):
        url = "http://" + author + ".tumblr.com/rss"

        bs = Util.xml_soup(url)
        items = bs.find_all("item")
        quotes = [];
        for item in items:
            title = item.find("title").contents[0].strip()
            if title != 'Photo' and title != 'Audio' and title != 'Video':
                quotes.append(item.find("title").contents[0])

        if not quotes:
            logger.warning("Could not find quotes for URL " + url)
            return []

        return [{"quote": random.choice(quotes), "author": author, "sourceName": "tumblr", "link": ""}]

    def get_for_author(self, author):
        return self.get_quote(author)

    def get_for_keyword(self, keyword):
        return []
    
    def get_random(self):
        return []