FAST_TAGS_VER := $(shell fast-tags --version 2>/dev/null)

DIR = .
NIX-DIR = ./nix
NIXPKGS = $(NIX-DIR)/nixpkgs.git.json
# TARGETS = "[ ./example-package.nix ]"
TARGETS = "[ ]"

# DEFAULT
.PHONY : default
default:
	@echo "No default action. Use specific make flags instead!"


# CABAL, HPACK, ...
# Running these on save of arbitrary package.yaml files in the editor instead
# Might return to these at some point though

# PKG-CABAL = $(DIR)/weba-table-servant.cabal
# PKG-NIX   = $(DIR)/weba-table-servant.nix

# $(PKG-CABAL) : package.yaml
# 	hpack package.yaml

# $(PKG-NIX) : $(PKG-CABAL)
# 	cabal2nix $(DIR) > $(PKG-NIX)


# NIX-SHELL

# Not used but keeping it for the future
# assert-ghc-shell := $(shell if [ -z $(NIX_GHC) ]; then echo "GHC is not installed. Enter nix-shell script (e.g. make shell)"; exit 1; fi;)

.PHONY : shell84
shell84 : nix-shell-check
ifndef NIX_GHC
	@touch nix-shell-check
	ln -sf `ghc-pkg list | head -1 | xargs` .
	nix-shell project.nix -A shell --arg targets $(TARGETS) --argstr compiler ghc843 --command "ghc-pkg list | head -1 | xargs | xargs -I {} ln -sf {} . ; ls -1 package.conf.d | sort > package.conf.d.ghc843.txt; return"
else
	$(error Already in GHC shell!)
endif

.PHONY : shell86
shell86 : nix-shell-check
ifndef NIX_GHC
	@touch nix-shell-check
	nix-shell project.nix -A shell --arg targets $(TARGETS) --argstr compiler ghc861 --command "ghc-pkg list | head -1 | xargs | xargs -I {} ln -sf {} . ; ls -1 package.conf.d | sort > package.conf.d.ghc861.txt; return"
else
	$(error Already in GHC shell!)
endif

# .PHONY : nix-shell-check
# nix-shell-check : project.nix $(PKG-NIX) nix/* nix-deps/*
nix-shell-check : project.nix nix/* nix-deps/*
	@echo "Some nix shell dependencies changed!"


# NIX

# make -B nix/nixpkgs.git.json to force update
$(NIXPKGS) :
	# Switch between the original nixpkgs at github or a local mirror/fork:
	# nix-prefetch-git https://github.com/NixOS/nixpkgs > $(NIXPKGS)
	cd /r-cache/git/github.com/NixOS/nixpkgs && \
		git fetch
	nix-prefetch-git /r-cache/git/github.com/NixOS/nixpkgs > $(NIXPKGS)


# TAGS GENERATION

.FORCE:

# hasktags seems to have problems because of lazy IO. Switched to fast-tags
tags : .FORCE haskdeps haskdeps-core
ifdef FAST_TAGS_VER
	fast-tags -RL . -o tags
else
	$(error fast-tags not installed! Are you in the right shell?)
endif

haskdeps :
ifdef NIX_GHC
	nix-build project.nix -A haskell-sources --argstr compiler $(GHC_VER) --arg targets $(TARGETS) -o haskdeps
else
	$(error Not in GHC shell!)
endif

haskdeps-core :
ifdef NIX_GHC
	rm -rf haskdeps-core
	mkdir  haskdeps-core
	grep -v "^#" core-packages.$(GHC_VER).txt | xargs -I P grep "^P-[0-9]" package.conf.d.$(GHC_VER).txt | sed -r "s|\.conf||" | xargs -I P sh -c 'cabal get P -d /cabal-cache; ln -s /cabal-cache/P ./haskdeps-core'
else
	$(error Not in GHC shell!)
endif


# CLEANING

.PHONY: clean-all
clean-all : clean-tmp clean-tags clean-build

.PHONY: clean-build
clean-build :
	cabal new-clean
	rm -r dist

.PHONY: clean-tags
clean-tags :
	rm -f  tags
	rm -f  haskdeps
	rm -rf haskdeps-core

.PHONY: clean-tmp
clean-tmp :
	rm -f  .ghc.environment.*
