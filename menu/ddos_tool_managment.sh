#!/bin/bash

check_enabled() {
  services=("mhddos" "distress" "db1000n")
  stop_service=0
  for service in "${services[@]}"; do
    sudo sv status "$service" >/dev/null
    if [[ $? == 0 ]]; then
      stop_service=1
      break
    fi
  done
  return "$stop_service"
}

stop_services() {
  adss_dialog "$(trans "Зупиняємо атаку")"
  mhddos_stop
  distress_stop
  db1000n_stop
  confirm_dialog "$(trans "Атака зупинена")"
  ddos_tool_managment
}

get_ddoss_status() {
  services=("mhddos" "distress" "db1000n")
  service=""

  for element in "${services[@]}"; do
    sudo sv status "$element" >/dev/null 2>&1
    if [[ $? == 0 ]]; then
      service="$element"
      break
    fi
  done
  if [[ -n "$service" ]]; then
    while true; do
      clear
      echo -e "${GREEN}$(trans "Запущено $service")${NC}"

      #Fix Kali
      #https://t.me/c/1764189517/301014
      #https://t.me/c/1764189517/300970
      #tail --lines=20 /var/log/syslog | grep -w "$service"
	  #Fix Parrot
      #journalctl -n 20 -u "$service.service" --no-pager
      tail --lines=20 /var/log/adss/current

      echo -e "${ORANGE}$(trans "Нажміть будь яку клавішу щоб продовжити")${NC}"

      sleep 3
      if read -rsn1 -t 0.1; then
        break
      fi
    done
    ddos_tool_managment
  else
    confirm_dialog "$(trans "Немає запущених процесів")"
  fi
  ddos_tool_managment
}

ddos_tool_managment() {
  menu_items=("$(trans "Статус атаки")")
  check_enabled
  enabled_tool=$?
  if [[ "$enabled_tool" == 1 ]]; then
    menu_items+=("$(trans "Зупинити атаку")")
  fi
  menu_items+=("MHDDOS" "DB1000N" "DISTRESS" "$(trans "Повернутись назад")")
  display_menu "$(trans "Управління ддос інструментами")" "${menu_items[@]}"
  status=$?
  if [[ "$enabled_tool" == 1 ]]; then
    case $status in
    1)
      get_ddoss_status
      ;;
    2)
      stop_services
      ;;
    3)
      initiate_mhddos
      ;;
    4)
      initiate_db1000n
      ;;
    5)
      initiate_distress
      ;;
    6)
      ddos
      ;;
    esac
  else
    case $status in
    1)
      get_ddoss_status
      ;;
    2)
      initiate_mhddos
      ;;
    3)
      initiate_db1000n
      ;;
    4)
      initiate_distress
      ;;
    5)
      ddos
      ;;
    esac
  fi
}
