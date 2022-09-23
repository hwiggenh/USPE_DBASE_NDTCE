package main

import (
	"fmt"
	"bytes"
	"encoding/binary"
	// ""io"
	"io/ioutil"
	// "path"
	// ""path/filepath"
	// ""os"
	// ""sort"
	// "time"
	// "encoding/json"
	// ""math"
	// "errors"
	// ""strings"
	// "strconv"
	// ""gonum.org/v1/gonum/floats"
	// ""hw.net/CRACK/GO/pkg/models"
	// "H "hw.net/MISC/pkg/helper"
	// "MM "hw.net/MISC/pkg/math"
    // DB "hw.net/MISC/pkg/db"
	// "database/sql"
)
func P(n ...interface{}) { fmt.Println(n...) }


func main() {
	fn :="/home/herotto/code/USPE_DBASE_NDTCE/DATA/TA001/TS001/1_1.raw"
	barr, err := ioutil.ReadFile(fn)
	if err != nil { P(err); return }
	
	int16arr := make([]int16,len(barr)/2)
	RB := bytes.NewReader(barr)
	err = binary.Read(RB, binary.LittleEndian, &int16arr)
	if err != nil { P(err); return }
	P("len(int16arr): ",len(int16arr))
	
	erg :=  make([]int,20)
	for i:=0;i<200;i++ {
		erg[i/10] += int(int16arr[i])
	}
	P(erg)
	
}
