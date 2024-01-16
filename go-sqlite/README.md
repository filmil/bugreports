# Repro

Check out the repository:

```
git clone https://github.com/filmil/bugreports.git
```

Go to the example directory:

```
cd bugreports/go-sqlite
```

Run the example programs:

```
┬─[fmil@fmil9:~/code/bugreports/go-sqlite]─[11:38:54 AM]
│ (g/b:main)
╰─>$ cd ex && rm -f test.sqlite && go run . && cd -
GetAnn: Next error: bad parameter or other API misuse: not an error (21)got: ⏎
┬─[fmil@fmil9:~/code/bugreports/go-sqlite]─[11:39:00 AM]
│ (g/b:main)
╰─>$ cd ex2 && rm -f test.sqlite && go run . && cd -
got: field⏎
```

`ex` is the run with `go-sqlite`. This errors out.

`ex2` is the run with `mattn/go-sqlite3`. This works as expected.

