#!/usr/bin/env python

# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.
import six
import abc


@six.add_metaclass(abc.ABCMeta)
class AbstractWrapperApi:
    @abc.abstractmethod
    def log_message(self, message):
        pass

    @abc.abstractmethod
    def cleanup(self):
        pass

    @abc.abstractmethod
    def get_capabilities(self):
        pass

    @abc.abstractmethod
    def set_flags(self, flags):
        pass
