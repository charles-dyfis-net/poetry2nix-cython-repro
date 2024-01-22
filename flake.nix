{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    poetry2nixFlake = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nixFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pythonPackageOverrides = (pyfinal: pyprev: {

          "babel" = let old = pyprev."babel"; in old.overridePythonAttrs rec {
            name = "python3.12-${old.pname}-${version}";
            version = "2.13.1";
            src = pkgs.fetchPypi {
              pname = "Babel";
              inherit version;
              hash = "sha256-M+CVLX3WN0r42/Z2jMTd88z+/CRPmYbUB0cE8vvRiQA=";
            };
          };

          "cython" = let old = pyprev."cython"; in old.overridePythonAttrs rec {
            name = "python3.12-${old.pname}-${version}";
            version = "3.0.8";
            src = pkgs.fetchPypi {
              pname = "Cython";
              inherit version;
              hash = "sha256-gzNCPY/Vdl58zuo6mYXdHgpd/rJzRinhou0tYjPTneY=";
            };
            patches = [];
          };

          "meson-python" = let old = pyprev."meson-python"; in old.overridePythonAttrs rec {
            name = "python3.12-${old.pname}-${version}";
            version = "0.15.0";
            src = pkgs.fetchPypi {
              pname = "meson_python";
              inherit version;
              hash = "sha256-/dtz7s1J6JwcQch5N82JwtC2WhxjuigjhoHUvZSE0m8";
            };
          };

          "pystemmer" = let old = pyprev."pystemmer"; in old.overridePythonAttrs rec {
            preConfigure = (old.preConfigure or "") + ''
              sed -i -e "s@'Cython>=0.28.5,<1.0'@'Cython>=0.28.5'@" setup.py
            '';
          };

          "pytest-mock" = let old = pyprev."pytest-mock"; in old.overridePythonAttrs rec {
            name = "python3.12-${old.pname}-${version}";
            doCheck = false;
            doInstallCheck = false;
            version = "3.12.0";
            src = pkgs.fetchPypi {
              pname = "pytest-mock";
              inherit version;
              hash = "sha256-MaQPA4wiytMih7tDkyBURR/1WD/wlLym9nXfL4vBpuk=";
            };
          };

          "sphinx" = let old = pyprev."sphinx"; in old.overridePythonAttrs rec {
            doInstallCheck = false;
            doCheck = false;
          };

        });
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              python312 = prev.python312.override { packageOverrides = pythonPackageOverrides; };
              meson = prev.meson.overrideAttrs (old: {
                patches = (old.patches or []) ++ [
                  (pkgs.fetchpatch {
                    url = "https://github.com/mesonbuild/meson/commit/20bcca39726803aba56fcc388332622d70605e1a.patch";
                    hash = "sha256-mZc3ueYkkJtQnnHJ80VCnIPOdPwwWUJKrqQ3C+CxVeo=";
                  })
                ];
              });
            })
          ];
        };
        # pkgs = nixpkgs.legacyPackages.${system};
        poetry2nix = poetry2nixFlake.lib.mkPoetry2Nix {
          inherit pkgs;
        };
        poetry2nixOverrides = [
          poetry2nix.defaultPoetryOverrides
          (self: super: {
            meson-python = super.meson-python.overridePythonAttrs (old: { buildInputs = (old.buildInputs or []) ++ [super.setuptools]; });
          })
        ];
        poetryEnv = poetry2nix.mkPoetryEnv {
          python = pkgs.python312;
          projectDir = self;
          extras = [ ];
          overrides = poetry2nixOverrides;
        };
      in
      {
        legacyPackages = pkgs;
        packages = {
          myapp = poetry2nix.mkPoetryApplication {
            python = pkgs.python312;
            projectDir = self;
            overrides = poetry2nixOverrides;
          };
          default = self.packages.${system}.myapp;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.myapp ];
          packages = [ pkgs.poetry ];
        };
      });
}
