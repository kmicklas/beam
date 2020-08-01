{ nixpkgs ? import ../nixpkgs {}, ghc ? nixpkgs.haskell.packages.ghc865.ghc }:
with nixpkgs;

let
  pythonPackages = python3Packages;

  pymdown-extensions = pythonPackages.buildPythonPackage {
    name = "pymdown-extensions-7.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/f8/18/4ecc803c94a5797e8598671cd52d01f247d785b629e52ef6d4d8022b59d0/pymdown-extensions-7.1.tar.gz";
      sha256 = "1dhi7j7bgx2w36kyhy1l6yspkcar7qvfnnf5sy6990c2rlf3vyav";
    };

    propagatedBuildInputs = with pythonPackages; [ markdown ];
    doCheck = false;

    meta = {
      homepage = https://github.com/facelessuser/pymdown-extensions;
      description = "Extension pack for Python Markdown.";
      license = stdenv.lib.licenses.mit;
    };
  };

  mkdocs-material = pythonPackages.buildPythonPackage {
    name = "mkdocs-material-5.4.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/68/51/317f54d732a16ba5c8126ebfbe52fa1eb92332e2529b3861b30014f5fd95/mkdocs-material-4.6.3.tar.gz";
      sha256 = "0b11xakfdv1fay2v2xpg1sm7vbn721xjz115fg42wnizn0sncj0x";
    };

    propagatedBuildInputs = with pythonPackages; [ pymdown-extensions pygments mkdocs ];

    meta = {
      homepage = https://squidfunk.github.io/mkdocs-material/;
      description = "A Material Design theme for MkDocs";
      license = stdenv.lib.licenses.mit;
    };
  };

  markdown-fenced-code-tabs = pythonPackages.buildPythonPackage {
    name = "markdown-fenced-code-tabs-0.2.0";
    src = fetchurl {
      url = https://pypi.python.org/packages/21/7a/0cee39060c5173cbd80930b720fb18f5cb788477c03214ccdef44ec91d85/markdown-fenced-code-tabs-0.2.0.tar.gz;
      sha256 = "05k5v9wlxgghw2k18savznxc1xgg60gqz60mka4gnp8nsxpz99zs";
    };

    propagatedBuildInputs = with pythonPackages; [ markdown ];

    meta = {
      homepage = https://github.com/yacir/markdown-fenced-code-tabs;
      description = "Generates Bootstrap HTML Tabs for Consecutive Fenced Code Blocks";
      license = stdenv.lib.licenses.mit;
    };
  };

  beamPython = python3.withPackages (ps: [ mkdocs mkdocs-material markdown-fenced-code-tabs ps.sqlparse ]);
in
  haskell.lib.buildStackProject {
    inherit ghc;
    name = "beam-env";
    buildInputs = [ beamPython mkdocs ];
    # buildInputs = [ postgresql bash beamPython mkdocs pv sqlite
    #                 ncurses libcxx icu gcc mysql zlib openssl stack gnupg dos2unix vim pcre ];
    LANG = "en_us.UTF-8";
    python = beamPython;
  }
