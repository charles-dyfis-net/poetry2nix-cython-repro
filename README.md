poetry2nix-cython-repro
=======================

This is a reproducer for issues encountered while trying to specify a newer Cython than that provided by nixpkgs when building with poetry2nix. It fixes all _other_ known issues encountered when trying to use pandas and Python 3.12 with poetry2nix using the 23.11 release of nixpkgs.

When building this repo with `nix -L build .#myapp`, the following error is seen:

```none
python3.12-pandas>   [10/151] Compiling Cython source /private/tmp/nix-build-python3.12-pandas-2.2.0.drv-0/pandas-2.2.0/pandas/_libs/tslibs/base.pyx
python3.12-pandas>   FAILED: pandas/_libs/tslibs/base.cpython-312-darwin.so.p/pandas/_libs/tslibs/base.pyx.c
python3.12-pandas>   cython -M --fast-fail -3 --include-dir /private/tmp/nix-build-python3.12-pandas-2.2.0.drv-0/pandas-2.2.0/.mesonpy-px67ipfh/pandas/_libs/tslibs '-X always_allow_keywords=true' /private/tmp/nix-build-python3.12-pandas-2.2.0.drv-0/pandas-2.2.0/pandas/_libs/tslibs/base.pyx -o pandas/_libs/tslibs/base.cpython-312-darwin.so.p/pandas/_libs/tslibs/base.pyx.c
python3.12-pandas>   Traceback (most recent call last):
python3.12-pandas>     File "/nix/store/7dr84423bqpbmvdbbj71d4xc796r42i5-python3.12-cython-0.29.36/bin/.cython-wrapped", line 9, in <module>
python3.12-pandas>       sys.exit(setuptools_main())
python3.12-pandas>                ^^^^^^^^^^^^^^^^^
python3.12-pandas>     File "/nix/store/7dr84423bqpbmvdbbj71d4xc796r42i5-python3.12-cython-0.29.36/lib/python3.12/site-packages/Cython/Compiler/Main.py", line 848, in setuptools_main
python3.12-pandas>       return main(command_line = 1)
python3.12-pandas>              ^^^^^^^^^^^^^^^^^^^^^^
python3.12-pandas>     File "/nix/store/7dr84423bqpbmvdbbj71d4xc796r42i5-python3.12-cython-0.29.36/lib/python3.12/site-packages/Cython/Compiler/Main.py", line 866, in main
python3.12-pandas>       result = compile(sources, options)
python3.12-pandas>                ^^^^^^^^^^^^^^^^^^^^^^^^^
python3.12-pandas>     File "/nix/store/7dr84423bqpbmvdbbj71d4xc796r42i5-python3.12-cython-0.29.36/lib/python3.12/site-packages/Cython/Compiler/Main.py", line 788, in compile
python3.12-pandas>       return compile_multiple(source, options)
python3.12-pandas>              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
python3.12-pandas>     File "/nix/store/7dr84423bqpbmvdbbj71d4xc796r42i5-python3.12-cython-0.29.36/lib/python3.12/site-packages/Cython/Compiler/Main.py", line 763, in compile_multiple
python3.12-pandas>       result = run_pipeline(source, options,
python3.12-pandas>                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
python3.12-pandas>     File "/nix/store/7dr84423bqpbmvdbbj71d4xc796r42i5-python3.12-cython-0.29.36/lib/python3.12/site-packages/Cython/Compiler/Main.py", line 518, in run_pipeline
python3.12-pandas>       from ..Build.Dependencies import create_dependency_tree
python3.12-pandas>     File "/nix/store/7dr84423bqpbmvdbbj71d4xc796r42i5-python3.12-cython-0.29.36/lib/python3.12/site-packages/Cython/Build/__init__.py", line 1, in <module>
python3.12-pandas>       from .Dependencies import cythonize
python3.12-pandas>     File "/nix/store/7dr84423bqpbmvdbbj71d4xc796r42i5-python3.12-cython-0.29.36/lib/python3.12/site-packages/Cython/Build/Dependencies.py", line 17, in <module>
python3.12-pandas>       from distutils.extension import Extension
python3.12-pandas>   ModuleNotFoundError: No module named 'distutils'
```

**This bug is caused by the use of Cython 0.29.36; however, all of `pyproject.toml`, `poetry.lock`, and overrides in the `flake.nix` specify Cython 3.0.8!**
