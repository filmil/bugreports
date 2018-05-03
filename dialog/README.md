This is an issue I'm having with running dialog utility inside
a docker container.

You will need `docker`, `git`, `GNU make`, `screen`, and some patience to build
the (large) container.

First, the setup:

```
cd
mkdir -p tmp
cd tmp
git clone git@github.com:filmil/bugreports.git
cd bugreports/dialog
```

Then issue:
```
make run
```

Result is below.

(baseline.png)

Now do the same within a `screen` session.

```
screen
# Get to a prompt within screen.
make run
```

Result is below.

(with-screen.png)

