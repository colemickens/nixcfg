{ authToken =
    "eyJhbGciOiJIUzI1NiJ9.eyJkYXQiOjk5fQ.tHAHICKd7Q8S_HOB18nRqg_SrvakRv2HPkVBqYp4u_8"
, binaryCaches =
    [ { name =
          "nixpkgs-wayland"
      , secretKey =
          "ZsU/hF9ECgAWWxh+/AF6CcS9pvcyCYblDdPvp0RGQdDeXDFogvExGRWF6GvlK1Cmsd0SjgisTyxGGj1H0c4tgA=="
      }
    , { name =
          "colemickens"
      , secretKey =
          "ptS+iivESw5U/Jo8VyVBW2rZFTQ0hZRZW0VpyYKFsHKggZuf1qiVRPaoqoLvyxw9wMvqfPs2mCi27rjhXhoaXg=="
      }
    , { name =
          "nixpkgs-colemickens"
      , secretKey =
          "6ZUt338E6JcMUcZqDABLs30wIz2pzcZps7PVVrLxeTWY8t+EPk7vs8yIR+JTLmswd4hRFya/BAZ68Caz5tqT3A=="
      }
    , { name =
          "nixpkgs-kubernetes"
      , secretKey =
          "P/3GanqABwQU2hY7jzvqcHShYSR6BPgXwPkNqCzOiaIW1kxzhpzF8dsNkGRZw4nzoKOLZtPrPybH3SBxL/vYVA=="
      }
    , { name =
          "azure"
      , secretKey =
          "6AbwcrZTxK53SS6+CLAKji1e1ymzkMMzoXCy+y1L2gfVzRXqlR4KfB3xtX9vT8Ew3hVqHYK3owUyLC2ldbxBMg=="
      }
    ] : List { name : Text, secretKey : Text }
}