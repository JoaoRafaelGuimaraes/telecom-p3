import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkManchesterDecoder(FrameBitProcessor);
    Reg#(Maybe#(Bit#(1))) prev <- mkReg(Invalid);
    Reg#(Bit#(3)) i <- mkReg(0);  // contador de 3 bits, vai de 0 a 7
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) in);
            Bit#(3) new_i = i;
            Bit#(1) output_val = ?;

            if (!isValid(in)) begin
                // Reset no final do quadro
                prev <= Invalid;
                new_i = 0;
                outFifo.enq(Invalid);
            end
            else begin
                let current = validValue(in);

                if (isValid(prev)) begin
                    let prev_val = validValue(prev);

                    if (current != prev_val) begin
                        if (i % 4 == 3) begin
                            new_i = i + 1;

                        end 
                        if (i % 4 == 1) begin
                            new_i = i - 1;

                        end 
                        if (new_i == 4) begin
                            if (prev_val == 0 && current == 1) begin
                                output_val = 1;
                                outFifo.enq(Valid(output_val));
                            end else if (prev_val == 1 && current == 0) begin
                                output_val = 0;
                                outFifo.enq(Valid(output_val));
                            end
                        end
                    end

                end

                prev <= Valid(current);
                new_i = new_i + 1;
            end

            i <= new_i;
            
        endmethod
    endinterface

    interface out = toGet(outFifo);
endmodule
