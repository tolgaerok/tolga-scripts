#!/usr/bin/env python3
# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
"""
Variety quotes plugin sourcing programming jokes from JokeAPI https://sv443.net/jokeapi/v2/
@author: p-ja
"""

import logging
import random

from locale import gettext as _
from variety.plugins.IQuoteSource import IQuoteSource
from variety.Util import Util
from variety.Util import cache

logger = logging.getLogger("variety")

class ProgrammingJokesSource(IQuoteSource):

    def __init__(self):
        super(IQuoteSource, self).__init__()
        self.jokes = []

    @classmethod
    def get_info(cls):
        return {
            "name": "Programming jokes",
            "description": _("Jokes about programmers and programming"),
            "version": "0.1",
            "author": "p-ja"
        }

    def activate(self):
        if self.active:
            return
        super(ProgrammingJokesSource, self).activate()
        self.active = True

    def deactivate(self):
        self.active = False
        self.jokes = []

    def needs_internet(self):
        return True

    def supports_search(self):
        return False

    def get_random(self):
        joke = self._get_joke()
        return self._map_joke(joke)

    def _map_joke(self, joke):
        return [
            {
                "quote": joke.get('joke', "Can't load joke. It's not funny..."),
                "author": None,
                "sourceName": 'JokeAPI',
                "link": None
            }
        ]

    def _get_joke(self):
        if self.jokes:
            joke = random.choice(self.jokes)
            self.jokes.remove(joke)
            return joke

        if not Util.internet_enabled:
            return {}

        try:
            jokes = self._fetch_jokes()
        except Exception as err:
            logger.warning("Failed to fetch jokes {}".format(err))
            return {}

        if not isinstance(jokes, dict):
            return {}

        if 'jokes' not in jokes:
            logger.warning("Invalid response. No jokes.")
            return {}

        self.jokes.extend(jokes['jokes'])

        return self.jokes[0]

    @cache(ttl_seconds=30, debug=True)
    def _fetch_jokes(self):
        logger.debug("Fetching jokes...")
        URL = "https://v2.jokeapi.dev/joke/Programming?type=single&amount=10"
        return Util.fetch_json(URL)
