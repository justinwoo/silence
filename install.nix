#!/usr/bin/env nix-shell
#!nix-shell install.nix --run install-silence-systemd-unit


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

  install-silence-systemd-unit = pkgs.writeShellScriptBin "install-silence-systemd-unit" ''
    service="silence.service"
    systemctl --user disable --now $service || echo "$service is already disabled"
    systemctl --user enable --now "${sdunit}/$service"
    systemctl --user daemon-reload
    systemctl --user reset-failed
  '';

in pkgs.mkShell {
  buildInputs = [
    install-silence-systemd-unit
  ];
}
