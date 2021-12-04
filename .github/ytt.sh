#!/bin/sh

search_dir="${PWD}/.github/workflows/.templates/template/*"
status=0

for filepath in ${search_dir} ; do
  echo "--- Template: $(basename "${filepath}") ---"
  ytt template \
    --file=.github/workflows/.templates/global \
    --file="${filepath}" \
    --output-files=.github/workflows/ || status=1
  echo ""
done

exit $status
