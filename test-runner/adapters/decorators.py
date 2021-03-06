#!/usr/bin/env python

# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.
import functools

from .print_message import print_message


def log_entry_and_exit(_func=None, *, print_args=True):
    """Print the function signature and return value"""

    def decorator_log_entry_and_exit(func):
        @functools.wraps(func)
        def wrapper_log_entry_and_exit(*args, **kwargs):
            if print_args:
                args_repr = [repr(a) for a in args]
                kwargs_repr = [f"{k}={v!r}" for k, v in kwargs.items()]
                signature = ", ".join(args_repr + kwargs_repr)
            else:
                if len(args) > 0:
                    signature = repr(args[0]) + ",__ARGUMENTS_REDACTED__"
                else:
                    signature = "__ARGUMENTS_REDACTED__"
            if "__self__" in dir(func):
                func_name = func.__self__.__class__.__name__ + "." + func.__name__
            elif len(args) > 0:
                func_name = args[0].__class__.__name__ + "." + func.__name__
            else:
                func_name = func.__name__
            print_message(f"Callng {func_name!r}({signature})")
            value = func(*args, **kwargs)
            print_message(f"{func_name!r} returned {value!r}")
            return value

        return wrapper_log_entry_and_exit

    if _func is None:
        return decorator_log_entry_and_exit
    else:
        return decorator_log_entry_and_exit(_func)
