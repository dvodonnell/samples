function pabst_pixval,cents,ints,num,minep,minth,epint,thint,klim

res=fltarr(num,(2*klim)+1,(2*klim)+1)

for i=0,num-1 do begin

print,cents[i,0],cents[i,1]
res[i,*,*]=ints[*,*,cents[i,0],cents[i,1]]

endfor

return,res

end
