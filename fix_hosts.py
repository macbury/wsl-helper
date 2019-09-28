import sys

def update_wsl_ip(new_ip):
    """ update ip """
    host_file = "C:\\Windows\System32\drivers\etc\hosts"
    with open(host_file, "r") as f:
        lines = f.readlines()

    domains = [
      "wsl.local"
    ]

    change = False
    found = False
    for i, line in enumerate(lines):
        for domain in domains:
            if len(line) > 5 and line.find(domain) > -1:
                found = True
                if line.find(new_ip) > -1:
                    print("not change: ip is same! " + line)
                else:
                    lines[i] = "{}\t{}\n".format(new_ip, domain)
                    print("change: ip is different! " + line)
                    change = True
                break

    if not found:
        for domain in domains:
          lines.append("{}\t{}\n".format(new_ip, domain))
          print("change: ip not exists!")
        change = True

    if lines and change:
        with open(host_file, "w") as f:
            f.write("".join(lines))


if __name__ == '__main__':
    ip = sys.argv[1]
    print("New ip: " + ip)
    update_wsl_ip(new_ip=ip)