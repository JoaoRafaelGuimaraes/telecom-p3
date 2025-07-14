import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkSFDLocator(FrameBitProcessor);
    Reg#(Bit#(1)) prev <- mkReg(0);
    Reg#(Bool) afterSfd <- mkReg(False);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) in);
            if (in matches tagged Valid .b) begin
                if (afterSfd) begin
                    outFifo.enq(Valid(b));
                end else begin
                    if (prev == 1 && b == 1) begin
                        afterSfd <= True;
                    end
                    prev <= b;
                end
            end else begin
                afterSfd <= False;
                prev <= 0;
                outFifo.enq(Invalid);
            end
        endmethod
    endinterface

    interface out = toGet(outFifo);
endmodule

