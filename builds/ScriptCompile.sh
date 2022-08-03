cd ..
repo_dir=$(pwd)
sse_dir="C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition"
cd "$sse_dir\Papyrus Compiler"
./PapyrusCompiler.exe "$repo_dir\Scripts\Source\StaticSkillLevelingEffectScript.psc" -f="TESV_Papyrus_Flags.flg" -i="$sse_dir\Data\Scripts\Source" -o="$repo_dir\builds"