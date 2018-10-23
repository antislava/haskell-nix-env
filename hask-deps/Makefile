# turtle.nix : turtle.sh
# 	sh turtle.sh > turtle.nix

%.nix : %.sh
	sh $< > $@

# ## TESTs ##
# make ./req.nix
# Depending on: .
# Building: req.nix

# make ./aeson-compat.nix
# This rule
# Building: aeson-compat.nix

# .FORCE:

# aeson-compat.nix : FORCE
# USE make -B when forcing update
# aeson-compat.nix :
# 	@echo "This rule"
# 	@echo "Building: "$@

# %.nix : .FORCE
# 	@echo "Depending on: "$<
# 	@echo "Building: "$@

