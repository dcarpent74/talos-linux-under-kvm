# set control plane IP variable

CONTROL_PLANE_IP="xxx.xxx.xxx.xx0"



# Use following command to set node and endpoint permanantly in config so you dont have to type it everytime

talosctl config endpoint --talosconfig ./talosconfig ${CONTROL_PLANE_IP}

talosctl config node --talosconfig ./talosconfig ${CONTROL_PLANE_IP}



# Bootstrap cluster

talosctl --talosconfig ./talosconfig bootstrap



# Generate kubeconfig

talosctl --talosconfig ./talosconfig kubeconfig .
