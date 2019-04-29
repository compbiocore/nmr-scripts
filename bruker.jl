using Glob
using Printf


#=
    Calculates offset based on one of two methods:
        1) Temperature dependent chemical shift of Water
        2) Given chemical shift of Proton Dimension (Direct Dimension)
=#

function offset(o1::Float64,o2::Float64,n2,temp::Float16,ppmW::Float64=0.0)
    tempC=temp-273
    if ppmW == 0.0
        ppmW=5.06-0.0122*tempC+0.0000211*tempC*tempC
    end
    gamma=0.101329118
    if n2 == "15N"
        println(n2)
        gamma=0.101329118
    elseif n2 == "13C"
        gamma=0.251449530
    end
    ppm2=offset_calc(o1,o2,ppmW,gamma)
    return @sprintf("%0.3f",ppmW), @sprintf("%0.3f",ppm2)
end


# Calaculate the offset in ppm of one frequency based on the ppm and gyromagnetic ratio of another

function offset_calc(o1::Float64, o2::Float64, ppm1::Float64, gamma::Float64)
    o10=o1/(1.0+ppm1*10^-6)
    o20=o10*gamma
    ppm2=(o2/o20-1.0)*10^6
    return ppm2
end


# Reads in Spectrometer Metadata from acqus file

function read_acqus()
    contents=read("acqus",String)
    decim=match(r"##\$DECIM=\s?([^\n]+)"s,contents).captures[1]
    dspfvs=match(r"##\$DSPFVS=\s?([^\n]+)"s,contents).captures[1]
    grpdly=match(r"##\$GRPDLY=\s?([^\n]+)"s,contents).captures[1]
    te=match(r"##\$TE=\s?([^\n]+)"s,contents).captures[1]
    return Dict("DECIM"=>decim, "DSPFVS"=>dspfvs, "GRPDLY"=>grpdly, "Temp"=>te)
end


# Reads in Channel specific Metadata from acqu#s file

function read_params(file::String)
    contents=read(file,String)
    freq=match(r"##\$SFO1=\s?([^\n]+)"s,contents).captures[1]
    nuc=match(r"##\$NUC1=\s<?([^>]+)"s,contents).captures[1]
    offset=match(r"##\$O1=\s?([^\n]+)"s,contents).captures[1]
    sw=match(r"##\$SW_h=\s?([^\n]+)"s,contents).captures[1]
    td=match(r"##\$TD=\s?([^\n]+)"s,contents).captures[1]
    fnmode=match(r"##\$FnMODE=\s?([^\n]+)"s,contents).captures[1]
    println(nuc," ",freq, " (", offset,") ", sw, " (", td, ") ")
    return Dict("nLAB"=>nuc, "nOBS"=>freq, "Offset"=>offset,"nSW"=>sw,"nN"=>td,"nMode"=>fnmode)
end


# FID.com for a 2D experiment

function write_fid_2D(direct,indirect,spectrom)
    open("fid.com","w") do f
        write(f,"#!/bin/csh\n")
        write(f,"\n")
        write(f,"bruk2pipe -in ./ser \\\n")
        write(f," -bad 0.0 -ext -aswap -AMX -decim $(spectrom["DECIM"]) -dspfvs $(spectrom["DSPFVS"]) -grpdly $(spectrom["GRPDLY"]) \\\n")
        write(f," -xN \t$(direct["nN"]) -yN \t$(indirect["nN"]) \\\n")
        write(f," -xT \t$(@sprintf("%.0f",round(parse(Int,direct["nN"])/2))) -yT \t$(@sprintf("%.0f",round(parse(Int,indirect["nN"])/2))) \\\n")
        write(f," -xMODE \tDQD -yMODE \t$(fnModes[parse(Int,indirect["nMode"])]) \\\n")
        write(f," -xSW \t$(direct["nSW"]) -ySW \t$(indirect["nSW"]) \\\n")
        write(f," -xOBS \t$(direct["nOBS"]) -yOBS \t$(indirect["nOBS"]) \\\n")
        write(f," -xCAR \t$(direct["ppm"]) -yCAR \t$(indirect["ppm"])  \\\n")
        write(f," -xLAB \t$(direct["nLAB"]) -yLAB \t$(indirect["nLAB"]) \\\n")
        write(f," -ndim \t 2 -aq2D \t States \\\n")
        write(f," -out ./test.fid -verb -ov\n")
        write(f,"\n")
        write(f,"sleep 5")
    end
end


# FID.com for a 3D experiment

function write_fid_3D(direct,indirect,indirect2,spectrom)
    open("fid.com","w") do f
        write(f,"#!/bin/csh\n")
        write(f,"\n")
        write(f,"bruk2pipe -in ./ser \\\n")
        write(f," -bad 0.0 -ext -aswap -AMX -decim $(spectrom["DECIM"]) -dspfvs $(spectrom["DSPFVS"]) -grpdly $(spectrom["GRPDLY"]) \\\n")
        write(f," -xN \t$(direct["nN"]) -yN \t$(indirect["nN"]) -zN \t$(indirect2["nN"]) \\\n")
        write(f," -xT \t$(@sprintf("%.0f",round(parse(Int,direct["nN"])/2))) -yT \t$(@sprintf("%.0f",round(parse(Int,indirect["nN"])/2))) -zT \t$(@sprintf("%.0f",round(parse(Int,indirect2["nN"])/2))) \\\n")
        write(f," -xMODE \tDQD -yMODE \t$(fnModes[parse(Int,indirect["nMode"])]) -zMODE \t$(fnModes[parse(Int,indirect2["nMode"])]) \\\n")
        write(f," -xSW \t$(direct["nSW"]) -ySW \t$(indirect["nSW"]) -zSW \t$(indirect2["nSW"]) \\\n")
        write(f," -xOBS \t$(direct["nOBS"]) -yOBS \t$(indirect["nOBS"]) -zOBS \t$(indirect2["nOBS"]) \\\n")
        write(f," -xCAR \t$(direct["ppm"]) -yCAR \t$(indirect["ppm"]) -zCAR \t$(indirect2["ppm"]) \\\n")
        write(f," -xLAB \t$(direct["nLAB"]) -yLAB \t$(indirect["nLAB"]) -zLAB \t$(indirect2["nLAB"]) \\\n")
        write(f," -ndim \t 3 -aq2D \t States \\\n")
        write(f," -out ./test%03d.fid -verb -ov\n")
        write(f,"\n")
        write(f,"sleep 5")
    end
end

###########Main Code#########

# Read in Bruker Acquisition Parameters
files=glob("acqu*s")

# Determine the number of dimensions (2 or 3)
fnum=length(files)

# Bruker fnModes
fnModes=Dict(1=>"QF",2=>"QSEQ",3=>"TPPI",4=>"States",5=>"States-TPPI",6=>"Echo-AntiEcho")

#Write FID.com for 2D or 3D
if fnum == 2
    direct=read_params("acqus")
    indirect=read_params("acqu2s")
    spectrom=read_acqus()
    direct["ppm"], indirect["ppm"]= offset(parse(Float64,direct["nOBS"]),parse(Float64,indirect["nOBS"]),indirect["nLAB"],parse(Float16,spectrom["Temp"]))
    write_fid_2D(direct,indirect,spectrom)
elseif fnum == 3
    direct=read_params("acqus")
    indirect=read_params("acqu2s")
    indirect2=read_params("acqu3s")
    spectrom=read_acqus()
    direct["ppm"], indirect["ppm"]= offset(parse(Float64,direct["nOBS"]),parse(Float64,indirect["nOBS"]),indirect["nLAB"],parse(Float16,spectrom["Temp"]))
    direct["ppm"], indirect2["ppm"]= offset(parse(Float64,direct["nOBS"]),parse(Float64,indirect2["nOBS"]),indirect2["nLAB"],parse(Float16,spectrom["Temp"]))
    write_fid_D(direct,indirect,indirect2,spectrom)
end

#Run FID.com
chmod("fid.com",0o777)
run(`./fid.com`)
