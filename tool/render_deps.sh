#!/bin/sh
cd "$(dirname "$0")/.."
dot -Tpdf dep_graph.dot > dep_graph.pdf
