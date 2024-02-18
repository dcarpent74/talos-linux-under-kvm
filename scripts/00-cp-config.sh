# set control plane IP variable

CONTROL_PLANE_IP="xxx.xxx.xxx.xx0"



# Generate talos config

talosctl gen config talos-cluster https://$CONTROL_PLANE_IP:6443 --output-dir .
