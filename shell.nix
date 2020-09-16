{ pkgs ? import <nixpkgs> {} }:

let
  cmd = "${pkgs.sox}/bin/play ${./silence.mp3}";

  sdunit = pkgs.writeTextFile {
    name = "silence";
    destination = "/silence.service";
    text = ''
      [Unit]
      Description=silence - play silence to prevent usb audio device suspend

      [Service]
      Type=simple
      Restart=always
      ExecStart=/bin/bash -c "${cmd}"

      [Install]
      WantedBy=default.target
    '';
  };

  install-systemd-unit = pkgs.writeShellScriptBin "install-systemd-unit" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash

    service="silence.service"
    systemctl --user disable --now $service || echo "$service is already disabled"
    systemctl --user enable --now "${sdunit}/$service"
    systemctl --user daemon-reload
    systemctl --user reset-failed
  '';

in pkgs.mkShell {
  buildInputs = [
    install-systemd-unit
  ];
}
