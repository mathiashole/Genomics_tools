#!/bin/bash

# ================================
# Bioinformatics Pipeline
# Alineación, recorte y construcción de árboles filogenéticos.
# ================================

# Verificar si se proporcionaron los argumentos correctos
if [ "$#" -lt 1 ]; then
    echo "Uso: $0 <multifasta.fasta> [opciones]"
    echo ""
    echo "Opciones:"
    echo "  -t, --trim            Recortar alineaciones con trimAl (activado por defecto)"
    echo "  -o, --output-dir DIR  Directorio de salida (por defecto: ./resultados)"
    echo "  -f, --format FORMAT   Formato de salida del árbol (newick, nexus) [por defecto: newick]"
    echo "  -h, --help            Mostrar esta ayuda"
    exit 1
fi

# ================================
# Variables por defecto
# ================================
TRIM=true
OUTPUT_DIR="./resultados"
TREE_FORMAT="newick"

# ================================
# Parsear los argumentos adicionales
# ================================
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--trim) TRIM=true ;;
        -o|--output-dir) OUTPUT_DIR="$2"; shift ;;
        -f|--format) TREE_FORMAT="$2"; shift ;;
        -h|--help) 
            echo "Uso: $0 <multifasta.fasta> [opciones]"
            echo ""
            echo "Opciones:"
            echo "  -t, --trim            Recortar alineaciones con trimAl (activado por defecto)"
            echo "  -o, --output-dir DIR  Directorio de salida (por defecto: ./resultados)"
            echo "  -f, --format FORMAT   Formato de salida del árbol (newick, nexus) [por defecto: newick]"
            exit 0
            ;;
        *) INPUT_FASTA="$1" ;;
    esac
    shift
done

# ================================
# Validaciones iniciales
# ================================
if [ ! -f "$INPUT_FASTA" ]; then
    echo "Error: El archivo $INPUT_FASTA no existe."
    exit 1
fi

# Crear el directorio de salida si no existe
mkdir -p "$OUTPUT_DIR"

# Obtener el nombre base del archivo sin extensión
BASENAME=$(basename "$INPUT_FASTA" .fasta)

# ================================
# Alineación con MAFFT
# ================================
ALIGNED_FASTA="${OUTPUT_DIR}/al_${BASENAME}.fasta"
echo "Alineando secuencias con MAFFT..."
if mafft "$INPUT_FASTA" > "$ALIGNED_FASTA"; then
    echo "Alineación completada: $ALIGNED_FASTA"
else
    echo "Error: Falló la alineación con MAFFT."
    exit 1
fi

# ================================
# Recorte de alineaciones con trimAl (opcional)
# ================================
if [ "$TRIM" = true ]; then
    TRIMMED_FASTA="${OUTPUT_DIR}/trim_${BASENAME}.fasta"
    echo "Recortando alineaciones con trimAl..."
    if trimal -in "$ALIGNED_FASTA" -out "$TRIMMED_FASTA" -automated1; then
        echo "Recorte completado: $TRIMMED_FASTA"
    else
        echo "Error: Falló el recorte con trimAl."
        exit 1
    fi
else
    TRIMMED_FASTA="$ALIGNED_FASTA"
    echo "Recorte desactivado. Usando alineación completa para el árbol filogenético."
fi

# ================================
# Construcción del árbol filogenético con IQ-TREE 2
# ================================
echo "Construyendo árbol filogenético con IQ-TREE 2..."
#if iqtree2 -s "$TRIMMED_FASTA" -B 1000 -m MFP --quiet -nt AUTO -pre "${OUTPUT_DIR}/${BASENAME}" -redo; then
if iqtree2 -s "$TRIMMED_FASTA" -m MFP -B 1000 -nt 16 --quiet -pre "${OUTPUT_DIR}/${BASENAME}" -redo; then
    echo "Árbol filogenético generado."
else
    echo "Error: Falló la construcción del árbol con IQ-TREE 2."
    exit 1
fi

# ================================
# Conversión del árbol al formato deseado (opcional)
# ================================
TREEFILE="${OUTPUT_DIR}/${BASENAME}.treefile"
if [ "$TREE_FORMAT" == "nexus" ]; then
    echo "Convirtiendo el árbol al formato Nexus..."
    seqret -sequence "$TREEFILE" -outseq "${TREEFILE%.treefile}.nexus"
    echo "Árbol en formato Nexus: ${TREEFILE%.treefile}.nexus"
else
    echo "Árbol en formato Newick (por defecto): $TREEFILE"
fi

# ================================
# Resumen de resultados
# ================================
echo ""
echo "Pipeline completado. Resumen de resultados:"
echo "------------------------------------------"
echo "Alineación: $ALIGNED_FASTA"
[ "$TRIM" = true ] && echo "Alineación recortada: $TRIMMED_FASTA"
echo "Árbol filogenético: ${TREEFILE%.treefile}.${TREE_FORMAT}"
echo "Directorio de salida: $OUTPUT_DIR"
echo "------------------------------------------"

exit 0
