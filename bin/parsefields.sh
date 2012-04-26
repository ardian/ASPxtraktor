perl DatabaseCSV.pl --DBI=dbi:mysql:database=business_registry_kosovo --user=jeffrey --password=mypass --ROOT=Business --input=$1 --output=$2 \
    --field=dnn_ctr437_ViewBizneset_lblEmri:business_name \
    --field=dnn_ctr437_ViewBizneset_lblAdresa:address \
    --field=dnn_ctr437_ViewBizneset_lblNrReg:RegNumber \
    --field=dnn_ctr437_ViewBizneset_lblPronari:Owner \
    --field=dnn_ctr437_ViewBizneset_lblAktivitetiKry:MainBusiness \
    --field=dnn_ctr437_ViewBizneset_lblNrPuntorve:Employees \
    --field=dnn_ctr437_ViewBizneset_lblDtThemelimit:Founding \
    --field=dnn_ctr437_ViewBizneset_lblAktiviteti:Activity \
    --field=dnn_ctr437_ViewBizneset_lblPersoni:Person \
    --field=dnn_ctr437_ViewBizneset_lblKapitali:Capital \
    --field=dnn_ctr437_ViewBizneset_lblnrTelefonit:Telephone \
    --field=dnn_ctr437_ViewBizneset_lblLlojiBiz:BusinessType \

