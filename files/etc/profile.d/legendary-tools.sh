# /tools to jeden obraz squashfs zamontowany tylko do odczytu; jego bin/ dopisujemy NA KOŃCU PATH,
# żeby uszkodzone narzędzie nie przesłoniło systemowego (lpm i zenitd mają kopie w /system/bin).
case ":$PATH:" in *:/tools/bin:*) ;; *) PATH="$PATH:/tools/bin"; export PATH ;; esac
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:/tools/share"
