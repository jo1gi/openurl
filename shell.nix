with import <nixpkgs> {};

mkShell {
  nativeBuildInputs = [
    crystal
    shards
  ];
}
